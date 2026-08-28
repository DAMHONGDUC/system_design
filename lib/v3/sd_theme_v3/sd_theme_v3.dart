import 'package:flutter/material.dart';

/// The colour slots System Design v3 widgets need that [ColorScheme] has no
/// name for. The package declares the contract; the host app fills it in and
/// registers it on `ThemeData.extensions`, so swapping palettes never touches
/// a widget.
///
/// Everything [ColorScheme] already names — primary, onPrimary, secondary,
/// error, surface — is read from `context.colorScheme` instead, and every
/// text style from `context.textTheme`. Only what neither of those covers
/// lives here.
///
/// **v3 is a generation, not a version of v2.** This class deliberately does
/// not extend, wrap or import `SdThemeV2`: the two ship side by side while an
/// app migrates, and a shared base would make every v2 slot a constraint on
/// v3's palette. The overlap in slot names is convergence, not inheritance.
///
/// v3 adds three groups v2 had no use for, all of them earned by Reseller Studio:
///
/// - **[profit] / [loss]** — money that reads as good or bad news at a
///   glance. Kept apart from [success]/[danger] on purpose: a $0 profit is
///   not a failure and a refund is not an error, so tinting money with the
///   status palette would say something the number does not.
/// - **[success] / [warning] / [danger] / [info]** — the status accents the
///   app maps its own domain states onto (stale inventory, sync failed, an
///   offer about to expire). The package never learns what a state means; it
///   is handed a colour from this set.
/// - **[border] / [divider]** — v2 is dark-only, where a surface step is
///   enough to separate two things. v3 ships light as well, and on a light
///   background a card needs a real edge.
@immutable
class SdThemeV3 extends ThemeExtension<SdThemeV3> {
  const SdThemeV3({
    required this.background,
    required this.surfaceModal,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textPlaceholder,
    required this.border,
    required this.divider,
    required this.profit,
    required this.loss,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.chartGrid,
    required this.barrier,
    required this.shadow,
  });

  /// The page behind every surface — one step below `colorScheme.surface`,
  /// which is the card.
  final Color background;

  /// The one surface every modal wears — bottom sheets and dialogs alike, so
  /// a dialog opening over a sheet is never a second shade.
  final Color surfaceModal;

  /// One step above the card, for anything that must stay visible while
  /// sitting *on* a card, a sheet or a dialog: snack bars, chart tooltips,
  /// selected rows.
  final Color surfaceElevated;

  /// One step *below* the card, for a well that holds content rather than
  /// floating above it: a search field's trough, a photo placeholder, the
  /// unfilled part of a progress bar.
  final Color surfaceSunken;

  final Color textPrimary;

  /// Muted body text — captions, subtitles, axis labels.
  final Color textSecondary;

  /// The faintest readable text — a disabled label, a timestamp that must not
  /// compete with the row it sits in.
  final Color textTertiary;

  /// Text standing in for a value that is not there yet: a field's hint, a
  /// picker's "not set".
  ///
  /// **A step below [textTertiary], and that gap is the whole point.**
  /// Tertiary is the faintest colour still meant to be *read*, and a hint
  /// drawn in it gets taken for a value the field already holds — the seller
  /// then taps past a field they have not filled in. Nothing a user is
  /// expected to read takes this colour.
  final Color textPlaceholder;

  /// The edge of a card, an input or a chip.
  final Color border;

  /// The rule between two rows of one list. Lighter than [border]: a divider
  /// separates siblings, a border encloses a thing.
  final Color divider;

  /// Money earned. See the class doc for why this is not [success].
  final Color profit;

  /// Money lost — a negative margin, a refund, a sale under cost.
  final Color loss;

  /// A state that is going well: shipped, delivered, synced, in stock.
  final Color success;

  /// A state that needs attention but is not broken: stale inventory, an
  /// offer expiring, low stock.
  final Color warning;

  /// A state that is broken and blocks the seller: sync failed, marketplace
  /// disconnected, payment declined.
  final Color danger;

  /// A neutral, purely informational accent — a hint, a "new" marker.
  final Color info;

  /// The recessive rule behind chart marks.
  final Color chartGrid;

  /// Scrim behind a modal route.
  final Color barrier;

  /// The colour a raised surface casts.
  ///
  /// **Expected to be fully transparent in a dark palette, and that is not a
  /// missing value.** A shadow separates a card from a lighter page behind
  /// it; on a near-black background there is nothing for it to darken, and a
  /// shadow tuned for light reads as dirt. Dark palettes lean on [border] and
  /// the surface step instead, which is why `SdCardV3` draws both and lets
  /// this one disappear.
  final Color shadow;

  /// Neutral defaults, so a widget still renders when the host app has not
  /// registered the extension. Debug builds assert first (see
  /// `context.sdTheme3`); this only keeps a release build from crashing.
  static const SdThemeV3 fallback = SdThemeV3(
    background: Color(0xFFF5F6F8),
    surfaceModal: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFEDEFF3),
    textPrimary: Color(0xFF11151C),
    textSecondary: Color(0xFF5B6472),
    textTertiary: Color(0xFF8D96A4),
    textPlaceholder: Color(0xFFB4BCC8),
    border: Color(0xFFDDE1E8),
    divider: Color(0xFFEDEFF3),
    profit: Color(0xFF12805C),
    loss: Color(0xFFC0362C),
    success: Color(0xFF12805C),
    warning: Color(0xFFB27100),
    danger: Color(0xFFC0362C),
    info: Color(0xFF2563C9),
    chartGrid: Color(0xFFE4E7EC),
    barrier: Color(0x99000000),
    shadow: Color(0x14101828),
  );

  @override
  SdThemeV3 copyWith({
    Color? background,
    Color? surfaceModal,
    Color? surfaceElevated,
    Color? surfaceSunken,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textPlaceholder,
    Color? border,
    Color? divider,
    Color? profit,
    Color? loss,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? chartGrid,
    Color? barrier,
    Color? shadow,
  }) => SdThemeV3(
    background: background ?? this.background,
    surfaceModal: surfaceModal ?? this.surfaceModal,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    surfaceSunken: surfaceSunken ?? this.surfaceSunken,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    textPlaceholder: textPlaceholder ?? this.textPlaceholder,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    profit: profit ?? this.profit,
    loss: loss ?? this.loss,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    info: info ?? this.info,
    chartGrid: chartGrid ?? this.chartGrid,
    barrier: barrier ?? this.barrier,
    shadow: shadow ?? this.shadow,
  );

  @override
  SdThemeV3 lerp(covariant SdThemeV3? other, double t) {
    if (other == null) return this;

    return SdThemeV3(
      background: Color.lerp(background, other.background, t)!,
      surfaceModal: Color.lerp(surfaceModal, other.surfaceModal, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      profit: Color.lerp(profit, other.profit, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      barrier: Color.lerp(barrier, other.barrier, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
