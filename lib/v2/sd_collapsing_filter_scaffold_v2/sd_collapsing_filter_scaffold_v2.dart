import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_pinned_filter_bar_v2/sd_pinned_filter_bar_v2.dart';
import '../sd_scaffold_v2/sd_scaffold_v2.dart';

/// A screen that is "a filter plus a scrolling list", where the filter follows
/// the reading direction: read on down the list and the whole filter row lifts
/// into the app bar, whose title and actions step aside for it; scroll back the
/// other way and everything comes straight back.
///
/// Shared by the medications tab and the export history so the two cannot drift
/// into two different behaviours. It owns three things:
/// - the [SdPinnedFilterBarV2] strip anchored under the app bar, and the app-bar
///   copy of [filter] that replaces it while collapsed;
/// - which of [title]/[actions] or [filter] the bar is showing;
/// - the scroll listening that decides, including the hysteresis that stops a
///   jittery finger flipping the bar back and forth.
///
/// **[body] pads its own top, and that padding must NOT change with the
/// collapse**: pad it once by `SdContentPaddingV2.belowPinnedFilterBar` (or
/// `SdContentPaddingV2.top` where [filter] is null). The strip's height stays
/// reserved at the very top of the content, which is only ever on screen while
/// expanded, so nothing jumps mid-scroll.
class SdCollapsingFilterScaffoldV2 extends StatefulWidget {
  const SdCollapsingFilterScaffoldV2({
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.filter,
    this.collapsible = true,
    super.key,
  });

  /// Shown in the bar while expanded, and gone while collapsed.
  final Widget title;

  /// Same deal as [title] — the bar's own actions are what the filter takes the
  /// room from.
  final List<Widget>? actions;

  final Widget? leading;

  /// The filter row. ONE widget, shown in the strip while expanded and in the
  /// bar while collapsed — never both, so a stateful chip cannot disagree with
  /// itself. Null means there is nothing to filter yet (an export history with
  /// no exports): no strip, no hand-off, the title keeps the bar.
  ///
  /// Hand over a bare row of chips: both places supply the horizontal scrolling
  /// for an overflowing one, so a scroll view here would nest two.
  final Widget? filter;

  /// False pins everything in place — the strip stays put and the bar keeps its
  /// title and actions however far the list scrolls. The medications tab passes
  /// false while its search field owns the bar: collapsing the field away
  /// mid-typing would take the search with it.
  final bool collapsible;

  /// The scrollable. See the note above about its top padding.
  final Widget body;

  @override
  State<SdCollapsingFilterScaffoldV2> createState() =>
      _CollapsingFilterScaffoldState();
}

class _CollapsingFilterScaffoldState
    extends State<SdCollapsingFilterScaffoldV2> {
  /// Calm, and the same 250ms the rest of the app's chrome moves in.
  static const Duration _duration = Duration(milliseconds: 250);

  /// How far the strip travels as it leaves, as a fraction of its own height —
  /// a small lift toward the bar it is handing itself to, not a full slide.
  static const Offset _liftOffset = Offset(0, -0.25);

  bool _collapsed = false;

  /// Distance travelled in the current direction. Reset when the finger turns
  /// around, so only sustained movement counts.
  double _drift = 0;

  /// Movement a drag has to sustain before the bar changes over.
  static double get _flipDistance => SdSpacingConstant.h16;

  bool _onScroll(ScrollUpdateNotification notification) {
    final double delta = notification.scrollDelta ?? 0;

    // Only the body's own scrollable, never a horizontal one nested in a row.
    if (notification.depth != 0) return false;
    // At the top there is nothing above the strip to read, so it always shows.
    if (notification.metrics.pixels <= 0) {
      _drift = 0;
      _setCollapsed(false);
      return false;
    }
    if (delta == 0) return false;
    if (delta.isNegative != _drift.isNegative) _drift = 0;

    _drift += delta;

    if (_drift > _flipDistance) _setCollapsed(true);
    if (_drift < -_flipDistance) _setCollapsed(false);

    return false;
  }

  void _setCollapsed(bool value) {
    if (_collapsed == value) return;
    setState(() => _collapsed = value);
  }

  @override
  void didUpdateWidget(SdCollapsingFilterScaffoldV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Whatever took the bar over (a search field) gets it back expanded.
    if (!widget.collapsible) {
      _drift = 0;
      _collapsed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget? filter = widget.filter;
    final bool collapsed = filter != null && widget.collapsible && _collapsed;

    return SdScaffoldV2(
      title: AnimatedSwitcher(
        duration: _duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: collapsed ? _BarFilter(child: filter) : widget.title,
      ),
      actions: collapsed ? null : widget.actions,
      leading: widget.leading,
      body: filter == null
          ? widget.body
          : Stack(
              children: <Widget>[
                NotificationListener<ScrollUpdateNotification>(
                  onNotification: _onScroll,
                  child: widget.body,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  // Still laid out while collapsed (its height is what the body
                  // padded for), just invisible and out of the way of taps.
                  child: IgnorePointer(
                    ignoring: collapsed,
                    child: AnimatedSlide(
                      offset: collapsed ? _liftOffset : Offset.zero,
                      duration: _duration,
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: collapsed ? 0 : 1,
                        duration: _duration,
                        curve: Curves.easeOutCubic,
                        child: SdPinnedFilterBarV2(
                          topInset: SdContentPaddingV2.appBarInset(context),
                          child: filter,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// The filter while it is in the app bar: leading-aligned, and swipeable
/// sideways for the same reason [SdPinnedFilterBarV2] is — a row of chips can
/// outgrow the bar in a long locale, and the bar must never overflow.
class _BarFilter extends StatelessWidget {
  const _BarFilter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }
}
