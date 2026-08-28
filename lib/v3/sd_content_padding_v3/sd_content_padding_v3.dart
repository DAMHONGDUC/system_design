import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

/// Every screen's content insets, in one class.
///
/// The rule this encodes:
/// - **[topGap] below the app bar**;
/// - **[bottomGap] above the safe area**;
/// - **[horizontal] either side.**
///
/// The device insets live HERE, not in `SdScaffoldV3`: a scaffold that
/// wrapped its body in a `SafeArea` would silently fight every screen that
/// also pads for something floating over it, and the two would double up. One
/// class computes it, every screen reads it, nothing adds it twice.
///
/// **v3's app bar is opaque and takes real layout space; its tab bar floats.**
/// So there is no `appBarInset` here — the `Scaffold` has already subtracted
/// the bar by the time a body builds — but there *is* a floating-bar
/// footprint, because `SdGlassNavBarV3` hovers over the content rather than
/// occupying a slot. The five tab screens pass `floatingNav: true` and every
/// other route does not.
///
/// The asymmetry is deliberate. A frosted app bar costs a shader pass on
/// every scroll frame of a list that can run to thousands of rows; the tab
/// bar is a fixed 64pt strip whose cost does not grow with the content, and
/// it is the one piece of chrome the whole app is judged by.
abstract final class SdContentPaddingV3 {
  /// The gutter: 16 either side of any content.
  static double get horizontal => SdSpacingConstant.w16;

  /// Gap between the app bar and the first item of content. **8, and every
  /// screen reads it from here** — owner's rule. The bar is already a band of
  /// empty space at its own bottom edge, so anything more under it reads as a
  /// hole between the chrome and the page — the more so now the bar is a full
  /// `kToolbarHeight` and carries that band itself.
  ///
  /// **It is a `SizedBox` the screen puts at the top of its content, never
  /// padding and never added to a bar's height** — owner's rule. A gap folded
  /// into [screen] or [fullBleed] is invisible at the call site, and a gap
  /// added to `SdAppBarV3.toolbarHeight` makes the bar measure taller than it
  /// draws, which is how a docked control ends up mis-set in a row whose
  /// height nobody can point at. Being a box in the tree, it can be seen,
  /// moved and skipped.
  static double get topGap => SdSpacingConstant.h8;

  /// Gap between the last item and whatever is below it: the safe area, or
  /// the floating nav pill on a tab screen. Scroll a list to its end and this
  /// is the breathing room you see.
  ///
  /// **The same value `SdContentPaddingV2.bottomGap` uses** — owner's rule, so
  /// the two generations end a list with identical air and a screenshot of one
  /// app can be held against the other.
  static double get bottomGap => SdSpacingConstant.h16;

  /// The one padding every `SdButtonV3` wears, whatever its variant — a
  /// filled, outlined and text button read the same size next to each other
  /// because none of them types its own.
  static EdgeInsets get button => EdgeInsets.symmetric(
    horizontal: SdSpacingConstant.w24,
    vertical: SdSpacingConstant.h12,
  );

  /// The inside of a card — `SdCardV3`'s default, and what anything drawing
  /// its own card-like surface should match.
  static EdgeInsets get card => EdgeInsets.all(SdSpacingConstant.w16);

  /// The inside of a list row that is not a card.
  static EdgeInsets get row => EdgeInsets.symmetric(
    horizontal: SdSpacingConstant.w16,
    vertical: SdSpacingConstant.h12,
  );

  /// Gap between two items of the same list — items, orders, listings,
  /// anything drawn as a stack of cards. One number for every list in the
  /// app, so two screens showing the same kind of thing cannot come out
  /// differently.
  static double get listItemGap => SdSpacingConstant.h12;

  /// Gap between two whole sections stacked on a screen — Home's overview,
  /// needs-attention and activity blocks. A different rhythm than
  /// [listItemGap]: these are distinct sections, not repeated rows.
  static double get sectionGap => SdSpacingConstant.h24;

  /// Gap above a pinned bottom action — the daylight between the last thing
  /// the content scrolled to and the button holding the bottom edge.
  static double get pinnedActionsGap => SdSpacingConstant.h16;

  /// Padding for a section heading (`SdSectionHeaderV3`): the gap that
  /// separates it from the group above, the gutter, and the small gap down to
  /// its own rows.
  ///
  /// [first] drops the top gap — the screen's [topGap] has already placed the
  /// first heading, and adding the separator on top of it makes a screen
  /// start noticeably lower than its neighbours.
  static EdgeInsets sectionHeader({bool first = false}) => EdgeInsets.fromLTRB(
    horizontal,
    first ? 0 : SdSpacingConstant.h24,
    horizontal,
    SdSpacingConstant.h8,
  );

  // --- The floating glass tab bar ---
  //
  // `SdGlassNavBarV3` floats over the content rather than taking a layout
  // slot, so its footprint is something every tab screen has to pad by. All
  // of it lives here, and nothing types one of these numbers at a call site:
  // that is exactly how a bar and the padding beneath it drift apart.

  /// Height of the floating tab bar itself, excluding how far it sits off the
  /// bottom edge.
  static double get floatingBarHeight => SdSpacingConstant.h64;

  /// Corner radius that makes the bar a true stadium: exactly half its
  /// height, so the short edges are full semicircles with no straight
  /// segment left. Derived, never typed.
  static double get floatingBarRadius => floatingBarHeight / 2;

  /// Side margin. The bar is inset from the screen edges — that detachment is
  /// what makes it read as floating rather than as a docked toolbar.
  static double get floatingBarHorizontal => SdSpacingConstant.w16;

  /// How far the current tab's glass capsule sits inside the bar on every
  /// side.
  ///
  /// Uneven on purpose: the bar is much taller than one destination is wide,
  /// so an even inset would leave the capsule reading as a circle in a
  /// stadium. The vertical figure is the one that sets [selectedTabRadius].
  static EdgeInsets get selectedTabInset => EdgeInsets.symmetric(
    horizontal: SdSpacingConstant.w4,
    vertical: SdSpacingConstant.h6,
  );

  /// The capsule's corner, **concentric** with the bar's — the outer radius
  /// less the inset between them, which is what keeps the two curves parallel
  /// instead of merely both round. Derived, never typed.
  static double get selectedTabRadius =>
      floatingBarRadius - selectedTabInset.vertical / 2;

  /// How far the bar sits above the bottom edge.
  ///
  /// **The same rule as `SdContentPaddingV2.navBarOffset`** — owner's call, so
  /// the two generations' floating bars sit identically and a screenshot of
  /// one app can be held against the other.
  ///
  /// The device's own bottom inset, clamped between [minNavBarOffset] and
  /// [maxNavBarOffset]. The floor stops the bar hugging the glass where the
  /// device asks for little or nothing — a Home-button iPhone, most Androids,
  /// the default test view, an iPad, landscape. The ceiling stops a deep inset
  /// pushing the bar visibly up the screen.
  ///
  /// Note what the ceiling costs on a portrait iPhone, whose home-indicator
  /// inset is 34: the bar lands 14 short of it, so its lower edge sits inside
  /// the strip iOS reserves for the indicator and the edge-swipe gesture. That
  /// is a deliberate trade of system clearance for a tighter bar, not an
  /// oversight — raise [maxNavBarOffset] to 34 to give the clearance back.
  static double navBarOffset(BuildContext context) {
    final double safeBottom = _viewBottom(context);

    return math.min(math.max(safeBottom, minNavBarOffset), maxNavBarOffset);
  }

  /// The floor under [navBarOffset]. Below this the bar reads as stuck to the
  /// bottom edge, whatever the device claims it needs.
  static double get minNavBarOffset => SdSpacingConstant.h16;

  /// The ceiling over [navBarOffset]. Above this the bar reads as floating
  /// away from the bottom rather than sitting at it.
  static double get maxNavBarOffset => SdSpacingConstant.h20;

  /// The bar's whole footprint — how far off the bottom it sits plus its own
  /// height. What anything drawn underneath has to clear.
  static double floatingBarInset(BuildContext context) =>
      navBarOffset(context) + floatingBarHeight;

  /// Where the last item ends.
  ///
  /// The five tab screens pass [floatingNav], because their content scrolls
  /// behind the glass bar and has to clear its whole footprint plus a gap.
  /// Everything else — a pushed detail, a sheet route — has nothing floating
  /// over it and takes [detailBottom].
  static double bottom(BuildContext context, {bool floatingNav = false}) =>
      floatingNav
      ? floatingBarInset(context) + bottomGap
      : detailBottom(context);

  /// Where the last item ends on a route with nothing floating over it.
  ///
  /// The device's own safe area, **floored** at [minDetailBottom]. The floor
  /// is the whole point — a Home-button iPhone and most Androids report 0, and
  /// without it the last row sits flush against the bottom edge of the glass.
  ///
  /// **Deliberately NOT [bottomGap] stacked on top of the inset.** A device
  /// reporting 34 already gives more room than the floor asks for, and adding
  /// a gap to a generous inset makes a detail screen look like it ends early.
  static double detailBottom(BuildContext context) =>
      math.max(_viewBottom(context), minDetailBottom);

  /// The floor under [detailBottom].
  static double get minDetailBottom => SdSpacingConstant.h24;

  /// The whole thing: gutter + [bottom].
  ///
  /// **No top inset.** [topGap] is a `SizedBox` the screen places itself —
  /// see that getter.
  static EdgeInsets screen(BuildContext context, {bool floatingNav = false}) =>
      EdgeInsets.fromLTRB(
        horizontal,
        0,
        horizontal,
        bottom(context, floatingNav: floatingNav),
      );

  /// Same vertical insets, no gutter — for a list of rows or cards that bring
  /// their own horizontal padding. Adding the gutter on top of theirs would
  /// push the rows off the grid the rest of the app sits on.
  ///
  /// **No top inset**, for the same reason as [screen].
  static EdgeInsets fullBleed(
    BuildContext context, {
    bool floatingNav = false,
  }) => EdgeInsets.only(
    bottom: bottom(context, floatingNav: floatingNav),
  );

  /// The status bar, read off the **view** — see [_viewBottom] for why the
  /// ambient `MediaQuery` is the wrong source.
  ///
  /// There is no `appBarInset` here and this is not one: v3's app bar is
  /// opaque, so `Scaffold` has already subtracted it and content needs no
  /// clearance. This exists for the one thing that draws its own chrome from
  /// the top of the window — `SdSearchHeaderV3`, whose `maxExtent` has no
  /// context to read from.
  static double statusBarInset(BuildContext context) =>
      MediaQueryData.fromView(View.of(context)).viewPadding.top;

  /// How far the keyboard covers the bottom of the window, or 0 when it is
  /// down. What a sheet holding a text field lifts itself by.
  ///
  /// Read from the ambient `MediaQuery` on purpose, and the only inset here
  /// that is: the keyboard is transient, and a route animating one open needs
  /// the value that changes with it rather than the window's resting state.
  static double keyboardInset(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  /// The device's bottom inset (home indicator), read off the **view** rather
  /// than the ambient `MediaQuery`.
  ///
  /// `Scaffold` wraps its body in `removePadding(removeBottom)` whenever there
  /// is a `bottomNavigationBar`, which subtracts `padding.bottom` from
  /// `viewPadding.bottom` too — so an ambient read from inside the shell's
  /// body returns 0 where the screen's own build got 34. The inset is a
  /// property of the window, so the view is the one place with a stable
  /// answer.
  static double _viewBottom(BuildContext context) =>
      MediaQueryData.fromView(View.of(context)).viewPadding.bottom;
}
