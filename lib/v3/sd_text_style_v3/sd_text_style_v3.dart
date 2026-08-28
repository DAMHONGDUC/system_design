import 'package:flutter/material.dart';

import '../sd_context_v3/sd_context_v3.dart';

/// The tweaks System Design v3 widgets make to a text style from
/// `context.textTheme3`. Anything else goes through `copyWith` at the call
/// site — these are here because they repeat everywhere.
///
/// Named with a `3` suffix so they never collide with v2's identically-shaped
/// extension while both generations are in one app.
extension SdTextStyleV3X on TextStyle {
  /// Semi-bold. Named `semiBold3`, not `w600`, so it never collides with a
  /// host app's own `TextStyle` extension.
  TextStyle get semiBold3 => copyWith(fontWeight: FontWeight.w600);

  /// Bold — a figure that is the point of its card, a total on a receipt.
  TextStyle get bold3 => copyWith(fontWeight: FontWeight.w700);

  /// The muted colour for captions and subtitles.
  TextStyle muted3(BuildContext context) =>
      copyWith(color: context.sdTheme3.textSecondary);

  /// The faintest readable colour — disabled labels, a timestamp that must
  /// not compete with its row.
  TextStyle faint3(BuildContext context) =>
      copyWith(color: context.sdTheme3.textTertiary);

  /// Text standing in for a value that is not there yet — a field's hint, a
  /// picker's "not set". Fainter than [faint3] on purpose; see
  /// `SdThemeV3.textPlaceholder`.
  TextStyle placeholder3(BuildContext context) =>
      copyWith(color: context.sdTheme3.textPlaceholder);

  /// Tabular figures, so a column of money does not jitter as digits change.
  ///
  /// Every price, cost, total and count in a list or a table takes this.
  /// Proportional digits are why a running total appears to shuffle sideways
  /// while it updates, and Reseller Studio is mostly columns of money.
  TextStyle get tabular3 =>
      copyWith(fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]);

  /// Struck through — an old price next to the new one after a reprice.
  TextStyle get struck3 => copyWith(decoration: TextDecoration.lineThrough);
}
