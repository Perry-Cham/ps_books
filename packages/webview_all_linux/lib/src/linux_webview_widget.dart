import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'linux_webview_controller.dart';
import 'linux_webview_creation_params.dart';

class LinuxWebViewWidget extends PlatformWebViewWidget {
  LinuxWebViewWidget(PlatformWebViewWidgetCreationParams params)
    : super.implementation(
        params is LinuxWebViewWidgetCreationParams
            ? params
            : LinuxWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
                params,
              ),
      );

  @override
  Widget build(BuildContext context) {
    final LinuxWebViewController controller =
        params.controller as LinuxWebViewController;
    return _LinuxPlatformWebView(controller: controller, key: params.key);
  }
}

class _LinuxPlatformWebView extends StatefulWidget {
  const _LinuxPlatformWebView({super.key, required this.controller});

  final LinuxWebViewController controller;

  @override
  State<_LinuxPlatformWebView> createState() => _LinuxPlatformWebViewState();
}

class _LinuxPlatformWebViewState extends State<_LinuxPlatformWebView>
    with WidgetsBindingObserver, RouteAware {
  Rect _lastRect = Rect.zero;
  /// The last non-zero, visible rect — used to restore after minimize.
  Rect _lastKnownGoodRect = Rect.zero;
  bool _attached = false;
  /// Whether we have already auto-grabbed focus for the current
  /// visible cycle.  Reset to false each time the webview is hidden
  /// so that re-showing will re-grab focus when [focusable] is true.
  bool _autoFocused = false;
  /// Whether a modal route (dialog, drawer, bottom sheet, etc.) is
  /// covering the webview.  When true the GTK widget is hidden so that
  /// Flutter-rendered overlays are visible on top.
  bool _obscuredByRoute = false;

  /// RouteObserver that notifies us when routes are pushed/popped above
  /// the webview's route, so we can hide/show the GTK widget for
  /// correct z-ordering with Flutter dialogs, drawers, and sheets.
  ///
  /// Found from the nearest [Navigator]'s observers list; may be `null`
  /// if no suitable [RouteObserver] is registered upstream, in which
  /// case route-awareness is unavailable.
  RouteObserver<ModalRoute<void>>? _routeObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribeToRouteObserver();
  }

  /// Subscribe to the nearest Navigator's [RouteObserver] so that
  /// [didPushNext] / [didPopNext] fire when modal routes are pushed or
  /// popped above the webview.
  void _subscribeToRouteObserver() {
    ModalRoute<void>? route;
    try {
      route = ModalRoute.of(context);
    } on Object {
      // Not under a ModalRoute — nothing to observe.
      return;
    }
    if (route == null) return;

    final NavigatorState? navigator = route.navigator;
    if (navigator == null) return;

    // Unsubscribe from previous observer.
    _routeObserver?.unsubscribe(this);

    // Find a RouteObserver already registered with the navigator.
    // In newer Flutter, NavigatorState no longer exposes a mutable
    // observers list, so we reuse the app-provided observer instead
    // of trying to inject our own.
    _routeObserver = navigator.widget.observers
        .whereType<RouteObserver<ModalRoute<void>>>()
        .firstOrNull;

    if (_routeObserver != null) {
      _routeObserver!.subscribe(this, route);
    }

    // If a modal is already showing above us (e.g. the widget is
    // built while a dialog is open), immediately hide the webview.
    final shouldObscure = !route.isCurrent;
    if (shouldObscure != _obscuredByRoute) {
      _obscuredByRoute = shouldObscure;
      if (shouldObscure && _attached) {
        _pushRect(Rect.zero, visible: false);
      }
    }
  }

  // ------------------------------------------------------------------
  // RouteAware — hide/show the GTK widget so Flutter overlays render
  // on top instead of behind the native WebKit overlay.
  // ------------------------------------------------------------------

  @override
  void didPushNext() {
    // A route (dialog, bottom sheet, drawer, etc.) was pushed on top
    // of the webview's route.  Hide the GTK widget so the Flutter-
    // rendered overlay is fully visible.
    _obscuredByRoute = true;
    _pushRect(Rect.zero, visible: false);
  }

  @override
  void didPopNext() {
    // The overlay route was popped — the webview's route is current
    // again.  Re-show the webview with its last known geometry.
    _obscuredByRoute = false;
    if (_lastKnownGoodRect != Rect.zero) {
      _pushRect(_lastKnownGoodRect, visible: true);
    }
  }

  // ------------------------------------------------------------------
  // WidgetsBindingObserver
  // ------------------------------------------------------------------

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_obscuredByRoute) {
      // A modal is still covering us — stay hidden.
      return;
    }
    if (_attached) {
      // Normal resize — re-push current rect.
      _pushRect(_lastRect, visible: _attached);
    } else if (_lastKnownGoodRect != Rect.zero) {
      // Restoring from minimize / virtual-desktop switch.
      // After minimize, onDetached() set _attached=false and
      // _lastRect=Rect.zero.  didChangeMetrics fires before the
      // render object is re-attached and paint() runs, so we must
      // re-apply the last known good rect here rather than waiting
      // for paint() which may be delayed.
      _pushRect(_lastKnownGoodRect, visible: true);
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    // Release GTK focus back to Flutter before destroying the webview.
    // Both calls are fire-and-forget because dispose() must be sync.
    // Method channels are ordered, so releaseFocus arrives before dispose.
    unawaited(widget.controller.releaseFocus());
    // Terminate the WebKit web process and destroy the native widget.
    unawaited(widget.controller.dispose());
    super.dispose();
  }

  void _pushRect(Rect rect, {required bool visible}) {
    _lastRect = rect;
    _attached = visible;
    if (visible && rect != Rect.zero) {
      _lastKnownGoodRect = rect;
    } else {
      // Reset so the next show will re-grab focus if focusable.
      _autoFocused = false;
    }
    unawaited(widget.controller.setFrame(rect, visible: visible));
    // Auto-grab GTK focus on the first visible paint when focusable.
    // This preserves backward compatibility for full-screen readers
    // where the webview should receive keyboard input by default.
    if (widget.controller.focusable &&
        visible &&
        !_autoFocused &&
        rect != Rect.zero) {
      _autoFocused = true;
      unawaited(widget.controller.requestFocus());
    }
  }

  void _handleGeometryChanged(Rect rect) {
    if (_obscuredByRoute) {
      // Don't show the webview while a modal is covering it.
      return;
    }
    final bool visible =
        rect.left.isFinite &&
        rect.top.isFinite &&
        rect.width.isFinite &&
        rect.height.isFinite &&
        rect.width > 0 &&
        rect.height > 0;
    if (_attached != visible || rect != _lastRect) {
      _pushRect(visible ? rect : Rect.zero, visible: visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LinuxGeometryObserver(
      onGeometryChanged: _handleGeometryChanged,
      onDetached: () => _pushRect(Rect.zero, visible: false),
      child: const SizedBox.expand(),
    );
  }
}

class _LinuxGeometryObserver extends SingleChildRenderObjectWidget {
  const _LinuxGeometryObserver({
    required this.onGeometryChanged,
    required this.onDetached,
    required Widget child,
  }) : super(child: child);

  final ValueChanged<Rect> onGeometryChanged;
  final VoidCallback onDetached;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _LinuxGeometryRenderBox(
      onGeometryChanged: onGeometryChanged,
      onDetached: onDetached,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _LinuxGeometryRenderBox renderObject,
  ) {
    renderObject
      ..onGeometryChanged = onGeometryChanged
      ..onDetached = onDetached;
  }
}

class _LinuxGeometryRenderBox extends RenderProxyBox {
  _LinuxGeometryRenderBox({
    required ValueChanged<Rect> onGeometryChanged,
    required VoidCallback onDetached,
  }) : _onGeometryChanged = onGeometryChanged,
       _onDetached = onDetached;

  ValueChanged<Rect> _onGeometryChanged;
  VoidCallback _onDetached;

  set onGeometryChanged(ValueChanged<Rect> value) {
    _onGeometryChanged = value;
  }

  set onDetached(VoidCallback value) {
    _onDetached = value;
  }

  @override
  void detach() {
    _onDetached();
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (!attached) {
      return;
    }
    final Matrix4 transform = getTransformTo(null);
    final Offset topLeft = MatrixUtils.transformPoint(transform, Offset.zero);
    final Offset bottomRight = MatrixUtils.transformPoint(
      transform,
      Offset(size.width, size.height),
    );
    final Rect rect = Rect.fromLTRB(
      math.min(topLeft.dx, bottomRight.dx),
      math.min(topLeft.dy, bottomRight.dy),
      math.max(topLeft.dx, bottomRight.dx),
      math.max(topLeft.dy, bottomRight.dy),
    );
    _onGeometryChanged(rect);
  }
}
