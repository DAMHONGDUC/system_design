import 'package:flutter/widgets.dart';

import '../../core/sd_spacing_constant.dart';

/// The corner radii v3 uses, named by what wears them rather than by size.
///
/// `SdSpacingConstant.r*` is the raw scale and stays the only place a number
/// is written; this maps meaning onto it. A call site asks for [card], not
/// for `r16` — so restyling every card is one edit here, and two widgets that
/// should match can never drift apart because someone typed the neighbouring
/// step.
final class SdRadiusV3 {
  /// Chips, badges, small status pills — anything that hugs a short label.
  static double get chip => SdSpacingConstant.r8;

  /// Text fields, dropdowns, segmented tracks.
  static double get input => SdSpacingConstant.r12;

  /// The default surface radius: cards, tiles, list sections.
  static double get card => SdSpacingConstant.r16;

  /// Buttons. One step under [card] so a button sitting inside a card reads
  /// as the nearer, smaller thing.
  static double get button => SdSpacingConstant.r12;

  /// Bottom sheets and dialogs — the largest radius in the system, and only
  /// the top two corners on a sheet.
  static double get modal => SdSpacingConstant.r24;

  /// Photo thumbnails and item images.
  static double get thumbnail => SdSpacingConstant.r12;

  /// Fully round — avatars, dots, the "999" trick for a stadium border.
  static double get full => SdSpacingConstant.r999;

  static BorderRadius get chipAll => BorderRadius.circular(chip);
  static BorderRadius get inputAll => BorderRadius.circular(input);
  static BorderRadius get cardAll => BorderRadius.circular(card);
  static BorderRadius get buttonAll => BorderRadius.circular(button);
  static BorderRadius get thumbnailAll => BorderRadius.circular(thumbnail);
  static BorderRadius get fullAll => BorderRadius.circular(full);

  /// A sheet rounds its top edge only — the bottom runs off-screen, and
  /// rounding it leaves two bright slivers of barrier in the corners.
  static BorderRadius get modalTop =>
      BorderRadius.vertical(top: Radius.circular(modal));
}
