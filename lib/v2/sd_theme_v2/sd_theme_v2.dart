import 'package:flutter/material.dart';

/// The colour slots System Design widgets need that `ColorScheme` has no name
/// for. The package declares the contract; the host app fills it in and
/// registers it on `ThemeData.extensions`, so swapping palettes never touches
/// a widget.
///
/// Everything `ColorScheme` already names — primary, onPrimary, secondary,
/// error, surface — is read from `Theme.of(context).colorScheme` instead, and
/// every text style from `Theme.of(context).textTheme`. Only what neither of
/// those covers lives here.
@immutable
class SdThemeV2 extends ThemeExtension<SdThemeV2> {
  const SdThemeV2({
    required this.background,
    required this.surfaceModal,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.chartGrid,
    required this.barrier,
  });

  /// The page behind every surface — one step below `colorScheme.surface`,
  /// which is the card.
  final Color background;

  /// The one surface every modal wears — bottom sheets and dialogs alike, so
  /// a dialog opening over a sheet is never a second shade of dark.
  ///
  /// A step *below* the card rather than above it: a modal already separates
  /// itself with the barrier scrim and its rounded corners, and going darker
  /// keeps the cards that sit on it reading as the nearer layer.
  final Color surfaceModal;

  /// One step above the card, for anything that must stay visible while
  /// sitting *on* a card, a sheet or a dialog: snack bars, chart tooltips,
  /// option tiles.
  final Color surfaceElevated;

  final Color textPrimary;

  /// Muted body text — captions, subtitles, axis labels.
  final Color textSecondary;

  /// The recessive rule behind chart marks.
  final Color chartGrid;

  /// Scrim behind a modal route.
  final Color barrier;

  /// Neutral dark defaults, so a widget still renders when the host app has
  /// not registered the extension. Debug builds assert first (see
  /// `context.sdTheme`); this only keeps a release build from crashing.
  static const SdThemeV2 fallback = SdThemeV2(
    background: Color(0xFF000000),
    surfaceModal: Color(0xFF161618),
    surfaceElevated: Color(0xFF2C2C2E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF98989F),
    chartGrid: Color(0xFF2C2C2E),
    barrier: Color(0x99000000),
  );

  @override
  SdThemeV2 copyWith({
    Color? background,
    Color? surfaceModal,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? chartGrid,
    Color? barrier,
  }) => SdThemeV2(
    background: background ?? this.background,
    surfaceModal: surfaceModal ?? this.surfaceModal,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    chartGrid: chartGrid ?? this.chartGrid,
    barrier: barrier ?? this.barrier,
  );

  @override
  SdThemeV2 lerp(covariant SdThemeV2? other, double t) {
    if (other == null) return this;

    return SdThemeV2(
      background: Color.lerp(background, other.background, t)!,
      surfaceModal: Color.lerp(surfaceModal, other.surfaceModal, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      barrier: Color.lerp(barrier, other.barrier, t)!,
    );
  }
}
