import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_app_bar_v3/sd_app_bar_v3.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_search_field_v3/sd_search_field_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

part 'sd_search_header_v3_delegate.dart';

/// One icon action in a header's trailing slot.
///
/// A value type rather than a widget, for the same reason
/// `SdNavDestinationV3` is one: the header reserves an exact width for the
/// trailing slot and subtracts it from the search field beside it. An action
/// that brought its own widget would size itself, and the field would either
/// overlap it or stop short of it by a number nobody could predict.
@immutable
class SdAppBarActionV3 {
  const SdAppBarActionV3({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;

  /// Tooltip and semantics label. A parameter because this package holds no
  /// strings.
  final String tooltip;

  final VoidCallback onPressed;

  /// The width one action occupies, and its tap target. Square, so the row of
  /// them is `count × slot` and the header can do that arithmetic without
  /// laying anything out.
  static double get slot => SdSpacingConstant.w44;
}

/// The header's own internal spacing, kept off `SdContentPaddingV3`.
///
/// The gap between the title row and the search field under it is the
/// *header's* geometry, not the screen's. It used to read
/// `SdContentPaddingV3.topGap`, which made `SdAppBarV3.toolbarHeight + topGap`
/// a real sum in this file — forbidden, because a bar that measures taller
/// than it draws is how a docked control ends up mis-set in a row whose height
/// nobody can point at. `topGap` is a `SizedBox` a screen places in its
/// content; this number is the distance between two things the header itself
/// draws, and they are not the same rule even when they are the same value.
final class SdSearchHeaderMetricsV3 {
  /// Between the title row and the expanded search field.
  static double get fieldGap => SdSpacingConstant.h8;

  /// Between the expanded search field and the pinned filter strip.
  static double get stripGap => SdSpacingConstant.h8;
}

/// The app bar for a screen whose search box *is* the screen — Inventory,
/// and later global search.
///
/// **The search field docks into the bar as the page scrolls.** At the top of
/// the list the header is two rows: the title with its actions, and the
/// search field under it. Scroll, and the title fades while the field travels
/// up into the title's row, ending beside the actions that never moved. The
/// **The header holds the title, the search field and the actions — nothing
/// else.** A filter strip is never part of the app bar; it is its own widget
/// in the body, `SdContentPaddingV3.topGap` below the chrome. Owner's rule.
///
/// So a seller who has scrolled 300 rows down still has search, filters and
/// the scanner in reach, and pays 48 points of chrome for them instead of
/// 148 — while a seller at the top of the list gets the title telling them
/// where they are.
///
/// **There is exactly one [SdSearchFieldV3] in the tree**, moved by
/// interpolating its rectangle. Cross-fading two fields would be easier to
/// write and would drop the keyboard, the cursor and the selection every time
/// the list crossed the threshold.
///
/// Returns a sliver: put it in a `CustomScrollView`, not in a `Scaffold.appBar`
/// slot. Its own height is layout, and `SdContentPaddingV3` does not carry it
/// for the same reason it carries no `appBarInset` — the sliver has already
/// taken the space by the time the list below it builds.
class SdSearchHeaderV3 extends StatelessWidget {
  const SdSearchHeaderV3({
    required this.title,
    required this.controller,
    required this.hint,
    required this.clearTooltip,
    this.onChanged,
    this.onSubmitted,
    this.actions = const <SdAppBarActionV3>[],
    super.key,
  });

  /// Shown only while the header is expanded — the field replaces it.
  final String title;

  final TextEditingController controller;
  final String hint;
  final String clearTooltip;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Always visible, in both states. The scanner belongs here rather than
  /// beside the field: it is a way *into* search, not a control of it.
  final List<SdAppBarActionV3> actions;


  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
    pinned: true,
    delegate: _SdSearchHeaderDelegateV3(
      // Read here, where there is a context: `maxExtent` has none, and a
      // header that guessed the status bar would sit under it.
      topPadding: MediaQuery.paddingOf(context).top,
      title: title,
      controller: controller,
      hint: hint,
      clearTooltip: clearTooltip,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      actions: actions,
    ),
  );
}
