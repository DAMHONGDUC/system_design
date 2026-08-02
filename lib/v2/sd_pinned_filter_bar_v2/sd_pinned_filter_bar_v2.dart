import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../sd_context_v2/sd_context_v2.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';
import '../sd_spacing_v2/sd_spacing_v2.dart';

/// A filter row anchored just below the app bar and floating above a scrolling
/// list: a fixed frosted strip that stays put on top while the list scrolls
/// underneath it, blurring content out through the same treatment as
/// [SdAppBarV2] so the two read as one continuous chrome strip.
///
/// It's a plain overlay box (NOT a sliver): drop it into a [Stack] over the
/// scrollable, positioned at the top, and pad the scrollable's top by
/// `SdContentPaddingV2.belowPinnedFilterBar` so its first item starts
/// below the strip.
///
/// [topInset] (the app-bar height the strip sits under) is passed in rather
/// than read from `MediaQuery` here: this widget builds inside the Scaffold
/// body, where a `MediaQuery` read can differ from the same read at the
/// body-building site that pads the list — measure it once at that site (via
/// `SdContentPaddingV2.appBarInset`) and hand the SAME value to both so the strip and
/// the list gap always line up.
class SdPinnedFilterBarV2 extends StatelessWidget {
  const SdPinnedFilterBarV2({
    required this.topInset,
    required this.child,
    super.key,
  });

  /// The app-bar height this strip is anchored under (kept transparent — the
  /// app bar paints over it).
  final double topInset;

  /// The filter content (e.g. a row of chips). Laid out left-aligned and
  /// horizontally scrollable so an overflowing row can be swiped sideways.
  final Widget child;

  /// Height of the visible filter strip below the app bar.
  static double get barHeight => SdSpacingV2.h56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: topInset + barHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Transparent: the app bar paints over this region.
          SizedBox(height: topInset),
          Expanded(child: _strip(context)),
        ],
      ),
    );
  }

  Widget _strip(BuildContext context) {
    final content = Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: SdSpacingV2.w16),
        child: child,
      ),
    );
    if (!SdGlassV2.isSupported) {
      return ColoredBox(color: context.sdTheme.background, child: content);
    }
    // Same frosted treatment as the app bar so the strip continues it.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: kChromeGlass.blur,
          sigmaY: kChromeGlass.blur,
        ),
        child: ColoredBox(
          color: context.sdTheme.background.withValues(alpha: 0.65),
          child: content,
        ),
      ),
    );
  }
}
