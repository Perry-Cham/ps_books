import 'package:flutter/foundation.dart';

/// A simple [ValueNotifier] that broadcasts the immersive-mode state to the
/// [ReaderShell] and every reader engine it hosts.
///
/// The shell owns the instance and passes it down to each engine via the
/// engine's constructor. Engines use [ValueListenableBuilder] + an
/// [AnimatedSlide] / [AnimatedOpacity] to hide/show their own chrome (page
/// count overlay, internal toolbars) in sync with the shell's AppBar.
///
/// Behaviour contract (per the user's spec):
///   - Mobile (Android/iOS): immersive mode is engaged automatically when
///     the reader opens; the AppBar + page-count overlay slide out of view.
///     The user exits immersive mode by tapping the centre of the screen.
///   - Desktop (Windows/macOS/Linux): immersive mode is engaged by tapping
///     the dedicated button in the AppBar. The user exits by tapping the
///     floating "hatch" button (a small FAB at the top-right corner).
///
/// The [ReaderShell] is responsible for those entry/exit triggers; this
/// class is purely the state-holder + notifier.
class ImmersiveModeController extends ValueNotifier<bool> {
  ImmersiveModeController([bool initial = false]) : super(initial);

  /// Whether immersive mode is currently engaged.
  bool get isImmersive => value;

  /// Engage immersive mode (slide chrome out of view).
  void enter() {
    if (!value) value = true;
  }

  /// Exit immersive mode (slide chrome back into view).
  void exit() {
    if (value) value = false;
  }

  /// Flip the current immersive state.
  void toggle() {
    value = !value;
  }

  @override
  String toString() => 'ImmersiveModeController(isImmersive: $value)';
}

/// Convenience platform check shared by the shell and the engines.
///
/// Uses [defaultTargetPlatform] (runtime value). Web is implicitly treated
/// as desktop here because the existing app does not ship a web build and
/// the reader has `dart:io` `Platform` usages that already break on web.
bool get isMobilePlatform =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;
