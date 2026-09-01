import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_app_bar_action_button_v3/sd_app_bar_action_button_v3.dart';
import '../sd_app_bar_v3/sd_app_bar_v3.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_search_field_v3/sd_search_field_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

part 'sd_search_header_v3_delegate.dart';

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
  ///
  /// **The only gap this header owns.** It used to carry a second one below
  /// the field, for the filter strip — but the strip is in the *body*, and
  /// the screen already places `SdContentPaddingV3.topGap` in front of it.
  /// Two boxes for one boundary is two owners for one number: Inventory's
  /// chips sat 8 lower than every other screen's and nothing in either file
  /// looked wrong on its own.
  static double get fieldGap => SdSpacingConstant.h8;
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
      // - measured once here and handed down: `maxExtent` has no context, and
      //   a header that guessed the status bar would sit under it
      // - off the view, never the ambient MediaQuery, which a Scaffold body
      //   has already had the top inset removed from
      topPadding: SdContentPaddingV3.statusBarInset(context),
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
