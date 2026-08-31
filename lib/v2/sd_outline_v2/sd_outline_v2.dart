import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// The app's one hairline outline — what a bordered box is drawn with,
/// wherever one is drawn.
///
/// A static holder rather than a widget, because the callers need it in
/// different shapes: [SdTextFieldV2] hands Material an `OutlineInputBorder`,
/// a plain box wants a [BoxDecoration]. Both read the same three values here,
/// so a field and the row beside it cannot come out a different grey or a
/// different radius.
///
/// The colour is the secondary text colour at [opacity], never a colour of its
/// own: a border is the quietest thing on a surface, and giving it a slot in
/// the palette would invite it to drift away from the text it frames.
final class SdOutlineV2 {
  const SdOutlineV2._();

  static const double width = 1;

  /// Low enough that the line frames without being read as content.
  static const double opacity = 0.28;

  static double get radius => SdSpacingConstant.r12;

  static Color color(BuildContext context) =>
      context.sdTheme.textSecondary.withValues(alpha: opacity);

  static BorderRadius get borderRadius => BorderRadius.circular(radius);

  static Border border(BuildContext context) =>
      Border.all(color: color(context), width: width);
}
