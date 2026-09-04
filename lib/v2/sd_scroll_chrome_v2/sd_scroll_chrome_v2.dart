import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

part 'sd_scroll_chrome_v2_slide.dart';

/// Which edge a piece of chrome leaves by while the body under it scrolls.
enum SdScrollChromeEdgeV2 {
  /// The app bar and the pinned filter strip: up, off the top.
  top,

  /// The shell's floating nav pill: down, off the bottom.
  bottom;

  /// Where the chrome sits while hidden, as a fraction of its own height —
  /// a whole one either way, so nothing is left peeking at the edge.
  Offset get hiddenOffset => switch (this) {
    SdScrollChromeEdgeV2.top => const Offset(0, -1),
    SdScrollChromeEdgeV2.bottom => const Offset(0, 1),
  };
}

/// Gives the chrome below it one shared answer to "is the body moving?", so
/// the app bar and the nav pill leave and come back together instead of each
/// listening to the scroll on its own.
///
/// The rule it encodes: **the list is the screen while you are reading it.**
/// Scroll and the chrome steps out of the way; stop — the finger lifts, the
/// fling settles, or the drag simply pauses — and it comes straight back.
/// Direction is deliberately not part of it: a list read upwards hides the
/// chrome exactly like one read downwards, so the app bar never flickers back
/// on a small correcting drag.
///
/// Wrap the shell once, above both the body and the bar (this is why it wraps
/// `SdBottomNavigationV2`'s whole `Scaffold` and not just its body: the pill
/// is in the scaffold's bottom slot, outside the body's subtree). Anything
/// with no scope above it — every route pushed over the shell — reads null
/// from [maybeOf] and keeps its chrome still, which is what a detail screen
/// wants: its back button is the only way out.
///
/// It carries a [ValueListenable] rather than rebuilding its subtree: the
/// only widgets that care are the two bits of chrome, and a `setState` here
/// would rebuild every list on every scroll gesture.
class SdScrollChromeV2 extends StatefulWidget {
  const SdScrollChromeV2({required this.child, super.key});

  final Widget child;

  /// Whether the chrome under [context] is showing, or null where nothing
  /// installed a scope — see the class doc.
  static ValueListenable<bool>? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SdScrollChromeScopeV2>()
      ?.visible;

  @override
  State<SdScrollChromeV2> createState() => _SdScrollChromeV2State();
}

class _SdScrollChromeV2State extends State<SdScrollChromeV2> {
  /// How long the body has to hold still before the chrome reads it as
  /// stopped. Covers the one case no notification reports: a finger that
  /// stays down but stops moving. Short enough to feel like a response to
  /// letting go, long enough that a slow drag does not flicker the bar back.
  static const Duration _idleDelay = Duration(milliseconds: 250);

  /// Movement the body has to add up to before the chrome leaves. Above the
  /// 18-pixel touch slop on purpose: a `Scrollable` reports the slop as its
  /// first delta, so anything at or under it would hide the chrome the
  /// instant a drag is recognised — and, more to the point, a scroll nobody
  /// asked for (a field scrolled into view above the keyboard) would take the
  /// bar with it.
  static double get _hideDistance => SdSpacingConstant.h24;

  final ValueNotifier<bool> _visible = ValueNotifier<bool>(true);

  /// Distance the body has moved since the chrome last settled, unsigned —
  /// see the class doc on why direction does not count.
  double _drift = 0;

  Timer? _idleTimer;

  @override
  void dispose() {
    _idleTimer?.cancel();
    _visible.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    // Only the body's own vertical scrollable: a row of filter chips swiped
    // sideways, or a chart's own gesture, is not the list being read.
    if (notification.depth != 0) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollEndNotification) {
      _settle();
      return false;
    }
    if (notification is! ScrollUpdateNotification) return false;

    // At the top there is nothing above the first row to make room for, so
    // the chrome shows however hard the list is being pulled.
    if (notification.metrics.pixels <= notification.metrics.minScrollExtent) {
      _settle();
      return false;
    }

    final double delta = notification.scrollDelta ?? 0;

    if (delta == 0) return false;

    _drift += delta.abs();
    if (_drift >= _hideDistance) _visible.value = false;
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleDelay, _settle);

    return false;
  }

  /// The body stopped: the chrome comes back, and the next gesture starts its
  /// own [_drift] from zero.
  void _settle() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _drift = 0;
    _visible.value = true;
  }

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
    onNotification: _onScroll,
    child: _SdScrollChromeScopeV2(visible: _visible, child: widget.child),
  );
}

/// Carries the notifier down. The notifier itself never changes identity, so
/// a rebuild of the scope tells its dependents nothing new.
class _SdScrollChromeScopeV2 extends InheritedWidget {
  const _SdScrollChromeScopeV2({required this.visible, required super.child});

  final ValueListenable<bool> visible;

  @override
  bool updateShouldNotify(_SdScrollChromeScopeV2 oldWidget) =>
      visible != oldWidget.visible;
}
