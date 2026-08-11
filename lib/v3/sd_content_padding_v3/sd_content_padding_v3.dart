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
/// **v3's chrome is opaque and takes real layout space** — a plain
/// [BottomNavigationBar] and an opaque app bar, not v2's floating glass pill.
/// So there is no `appBarInset` here and no nav-bar footprint to clear: the
/// `Scaffold` has already subtracted both by the time a body builds, and a
/// screen owes only the gaps. That is the single biggest difference between
/// the two generations' padding, and the reason this class is a fifth of the
/// size of v2's.
abstract final class SdContentPaddingV3 {
  /// The gutter: 16 either side of any content.
  static double get horizontal => SdSpacingConstant.w16;

  /// Gap between the app bar and the first item of content.
  static double get topGap => SdSpacingConstant.h16;

  /// Gap between the last item and whatever is below it.
  static double get bottomGap => SdSpacingConstant.h24;

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

  /// Where the last item ends: the device's own safe area, floored at
  /// [minBottom].
  ///
  /// The floor is the whole point — a Home-button iPhone and most Androids
  /// report 0, and without it the last row sits flush against the bottom edge
  /// of the glass. Deliberately NOT [bottomGap] stacked on top of the inset: a
  /// device reporting 34 already gives more room than the floor asks for.
  static double bottom(BuildContext context) =>
      math.max(_viewBottom(context), minBottom);

  /// The floor under [bottom].
  static double get minBottom => SdSpacingConstant.h24;

  /// The whole thing: gutter + [topGap] + [bottom].
  static EdgeInsets screen(BuildContext context) => EdgeInsets.fromLTRB(
    horizontal,
    topGap,
    horizontal,
    bottom(context),
  );

  /// Same vertical insets, no gutter — for a list of rows or cards that bring
  /// their own horizontal padding. Adding the gutter on top of theirs would
  /// push the rows off the grid the rest of the app sits on.
  static EdgeInsets fullBleed(BuildContext context) => EdgeInsets.only(
    top: topGap,
    bottom: bottom(context),
  );

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
