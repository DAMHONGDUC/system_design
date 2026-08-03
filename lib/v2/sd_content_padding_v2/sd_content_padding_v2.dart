import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';
import '../sd_pinned_filter_bar_v2/sd_pinned_filter_bar_v2.dart';

/// Every screen's content insets, in one class.
///
/// The rule this encodes, for all content in the app:
/// - **[topGap] below the app bar** (the body scrolls *behind* the frosted
///   bar, so it is measured from the bar's bottom edge, not the viewport);
/// - **[bottomGap] above the safe area** — and on the five tab screens also
///   clear of the floating nav pill the content scrolls behind;
/// - **[horizontal] either side.**
///
/// The device insets live HERE, not in `SdScaffoldV2`: a scaffold that wrapped
/// its body in a `SafeArea` would silently fight every screen that also has
/// to pad for something floating over it, and the two would double up. One
/// class computes it, every screen reads it, nothing adds it twice.
///
/// Floating chrome is the exception and asks for none of this: the app's two
/// floating bottom bars — the shell's nav pill and the log flow's step bar —
/// share [navBarOffset] off the bottom edge and [floatingBarHorizontal] off
/// the side edges, so the two pills always agree.
abstract final class SdContentPaddingV2 {
  /// The gutter: 16 either side of any content.
  static double get horizontal => SdSpacingConstant.w16;

  /// Gap between the app bar and the first item of content. Separate from
  /// [bottomGap] on purpose: the two edges are different problems — this one
  /// is breathing room under chrome, that one is thumb room above the home
  /// indicator — and each can move without dragging the other with it.
  static double get topGap => SdSpacingConstant.h8;

  /// Gap between the last item — usually the bottom action — and whatever is
  /// below it: the safe area, or the floating nav pill on a tab screen. Scroll
  /// a list to its end and this is the breathing room you see.
  static double get bottomGap => SdSpacingConstant.h16;

  /// Height of the app's floating bottom bars — the shell's nav pill and the
  /// log flow's step bar. Both read it and neither hardcodes its own: the two
  /// numbers drifted apart once (68 assumed here against a 56-tall bar), and
  /// the difference was silently eaten out of [bottomGap].
  static double get floatingBarHeight => SdSpacingConstant.h56;

  /// Corner radius that turns a floating bar into a true stadium: exactly half
  /// its height, so the short edges are full semicircles with no straight
  /// segment left. Derived, never typed — it was a literal 34 against a
  /// 56-tall bar and only looked right because the shape clamps it.
  static double get floatingBarRadius => floatingBarHeight / 2;

  /// Side margin shared by the app's two floating bottom bars — the shell's
  /// nav pill and the log flow's step bar — so both lift off the edges by the
  /// same amount. Its own field rather than a bare [SdSpacingConstant.w24] at
  /// each call site: that is exactly how the two drifted apart before this
  /// existed.
  static double get floatingBarHorizontal => SdSpacingConstant.w24;

  /// How far the app's two floating bottom bars — the shell's nav pill and the
  /// log flow's step bar — sit above the bottom edge of the screen. Both read
  /// this, not their own copy, so they always agree.
  ///
  /// The device's own bottom inset, clamped between [minNavBarOffset] and
  /// [maxNavBarOffset].
  ///
  /// The floor stops a bar hugging the glass where the device asks for
  /// little or nothing — a Home-button iPhone, most Androids, the default
  /// test view, an iPad, landscape. The ceiling stops a deep inset pushing
  /// the bar visibly up the screen.
  ///
  /// Note what the ceiling costs on a portrait iPhone, whose home indicator
  /// inset is 34: the bar lands 14 short of it, so its lower edge sits inside
  /// the strip iOS reserves for the indicator and the edge-swipe gesture.
  /// That is a deliberate trade of system clearance for a tighter bar, not an
  /// oversight — raise [maxNavBarOffset] to 34 to give the clearance back.
  static double navBarOffset(BuildContext context) {
    final double safeBottom = _viewBottom(context);

    return math.min(math.max(safeBottom, minNavBarOffset), maxNavBarOffset);
  }

  /// The floor under [navBarOffset]. Below this the pill reads as stuck to the
  /// bottom edge, whatever the device claims it needs.
  static double get minNavBarOffset => SdSpacingConstant.h16;

  /// The ceiling over [navBarOffset]. Above this the pill reads as floating
  /// away from the bottom rather than sitting at it.
  static double get maxNavBarOffset => SdSpacingConstant.h20;

  /// How far down the app bar reaches: status bar + toolbar while the bar is
  /// frosted glass (the body passes behind it), 0 when it is opaque and the
  /// body already starts below it.
  ///
  /// Use this only to *align* something to the bar — a pinned filter strip,
  /// a refresh indicator. Content wants [top], which adds the gap.
  ///
  /// Reads the status bar off the **view**, not off the ambient
  /// `MediaQuery`: `Scaffold` wraps its body in `removePadding(removeTop)`
  /// whenever there is an app bar, and that subtracts the status bar from
  /// `viewPadding.top` too. A body-side caller would get just
  /// [kToolbarHeight] where the screen's own build got the full height — and
  /// the bar would silently cover the first 47 logical pixels of content.
  /// The status bar is a property of the window, so the answer is the same
  /// anywhere in the tree.
  static double appBarInset(BuildContext context) => SdGlassV2.isSupported
      ? MediaQueryData.fromView(View.of(context)).padding.top + kToolbarHeight
      : 0;

  /// Top inset under a [SdPinnedFilterBarV2]: the app bar plus the strip pinned
  /// beneath it. What a scrollable behind that strip pads by, and what a
  /// refresh spinner drops below.
  static double belowPinnedFilterBar(BuildContext context) =>
      appBarInset(context) + SdPinnedFilterBarV2.barHeight;

  /// Padding for a section heading (`SdSectionHeaderV2`): the gap that
  /// separates it from the group above, the list gutter, and the small gap
  /// down to its own rows.
  ///
  /// [first] drops the top gap. The screen's [topGap] has already placed the
  /// first heading; adding the separator on top of it is what made Settings
  /// start noticeably lower than Insights, whose first item is a plain card.
  ///
  /// The gutter here is the *list's* (16), not [horizontal]: the heading
  /// lines up with the left edge of the `ListTile`s under it.
  static EdgeInsets sectionHeader({bool first = false}) => EdgeInsets.fromLTRB(
    SdSpacingConstant.w16,
    first ? 0 : SdSpacingConstant.h24,
    SdSpacingConstant.w16,
    SdSpacingConstant.h8,
  );

  /// First item starts [topGap] below the app bar.
  static double top(BuildContext context) => appBarInset(context) + topGap;

  /// Where the last item ends.
  ///
  /// The shell's five tab screens pass [floatingNav] — their content scrolls
  /// behind the nav pill, so it clears the pill's whole footprint plus
  /// [bottomGap]. Everything else — a pushed detail, a sheet route — takes
  /// [detailBottom], which is a different rule and says so.
  static double bottom(BuildContext context, {bool floatingNav = false}) =>
      floatingNav ? _navInset(context) + bottomGap : detailBottom(context);

  /// Bottom inset for a screen with nothing floating over it.
  ///
  /// The device's own safe area, floored at [minDetailBottom]. The floor is
  /// the whole point: a Home-button iPhone and most Androids report 0, and
  /// without it the last row would sit flush against the bottom edge of the
  /// glass with nothing under it.
  ///
  /// Deliberately NOT [bottomGap] on top of the inset. A device that reports
  /// 34 already gives the row more room than the floor asks for, and stacking
  /// a gap on top of a generous inset is what makes a detail screen look like
  /// it ends early.
  static double detailBottom(BuildContext context) =>
      math.max(_viewBottom(context), minDetailBottom);

  /// The floor under [detailBottom].
  static double get minDetailBottom => SdSpacingConstant.h20;

  /// The whole thing: gutter + [top] + [bottom].
  static EdgeInsets screen(BuildContext context, {bool floatingNav = false}) =>
      EdgeInsets.fromLTRB(
        horizontal,
        top(context),
        horizontal,
        bottom(context, floatingNav: floatingNav),
      );

  /// Same vertical insets, no gutter — for a list of `ListTile`s or cards
  /// that bring their own horizontal padding. Adding 24 on top of theirs
  /// would push the rows off the grid the rest of the app sits on.
  static EdgeInsets fullBleed(
    BuildContext context, {
    bool floatingNav = false,
  }) => EdgeInsets.only(
    top: top(context),
    bottom: bottom(context, floatingNav: floatingNav),
  );

  /// Bottom inset for a floating bar handed to `Scaffold.bottomNavigationBar`
  /// — the log flow's step bar. Shares [navBarOffset] with the shell's nav
  /// pill, so the body clears exactly what the bar occupies; unlike the nav
  /// pill it only floats where glass is supported, otherwise it takes a real
  /// layout slot, clears the safe area itself, and the body owes only the gap.
  static double bottomBar(BuildContext context) => SdGlassV2.isSupported
      ? navBarOffset(context) + floatingBarHeight + bottomGap
      : bottomGap;

  /// The nav pill's footprint: how far off the bottom edge it sits, plus its
  /// own height.
  static double _navInset(BuildContext context) =>
      navBarOffset(context) + floatingBarHeight;

  /// The device's bottom inset (home indicator), off the **view** — the same
  /// reason [appBarInset] reads the view at the top.
  ///
  /// `Scaffold` wraps its body in `removePadding(removeBottom)` whenever there
  /// is a `bottomNavigationBar`, and that subtracts `padding.bottom` from
  /// `viewPadding.bottom` too — so an ambient read from inside the shell's
  /// body returns 0 where the screen's own build got 34, and content came out
  /// 34 short: the last row of every tab screen ended up *behind* the nav
  /// pill. The inset is a property of the window, so the view is the one place
  /// with a stable answer.
  static double _viewBottom(BuildContext context) =>
      MediaQueryData.fromView(View.of(context)).viewPadding.bottom;
}
