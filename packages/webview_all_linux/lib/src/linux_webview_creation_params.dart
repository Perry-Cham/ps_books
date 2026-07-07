import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

@immutable
class LinuxWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  const LinuxWebViewControllerCreationParams({
    this.developerExtrasEnabled,
    this.javascriptCanOpenWindowsAutomatically,
    this.mediaPlaybackRequiresUserGesture,
    this.mediaPlaybackAllowsInline,
    this.pageCacheEnabled,
    this.allowFileAccessFromFileUrls,
    this.allowUniversalAccessFromFileUrls,
    this.zoomTextOnly,
    this.defaultFontSize,
    this.defaultMonospaceFontSize,
    this.minimumFontSize,
    this.zoomFactor,
  });

  const LinuxWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    PlatformWebViewControllerCreationParams params,
  ) : this();

  final bool? developerExtrasEnabled;
  final bool? javascriptCanOpenWindowsAutomatically;
  final bool? mediaPlaybackRequiresUserGesture;
  final bool? mediaPlaybackAllowsInline;
  final bool? pageCacheEnabled;
  final bool? allowFileAccessFromFileUrls;
  final bool? allowUniversalAccessFromFileUrls;
  final bool? zoomTextOnly;
  final int? defaultFontSize;
  final int? defaultMonospaceFontSize;
  final int? minimumFontSize;
  final double? zoomFactor;
}

@immutable
class LinuxWebViewWidgetCreationParams
    extends PlatformWebViewWidgetCreationParams {
  const LinuxWebViewWidgetCreationParams({
    super.key,
    required super.controller,
    super.layoutDirection,
    super.gestureRecognizers,
  });

  LinuxWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
    PlatformWebViewWidgetCreationParams params,
  ) : this(
        key: params.key,
        controller: params.controller,
        layoutDirection: params.layoutDirection,
        gestureRecognizers: params.gestureRecognizers,
      );
}

@immutable
class LinuxNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  const LinuxNavigationDelegateCreationParams();

  const LinuxNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    PlatformNavigationDelegateCreationParams params,
  );
}
