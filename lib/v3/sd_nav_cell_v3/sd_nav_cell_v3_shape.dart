part of 'sd_nav_cell_v3.dart';

/// What a destination looks like in the chrome that is drawing it.
enum SdNavCellShapeV3 {
  /// The phone's pill: a glyph alone in an equal segment. There is no room
  /// for a word across five of them at phone width, which is the whole reason
  /// that chrome is glyph-only.
  glyph,

  /// The tablet's panel: a glyph and its label, one row. A tablet has the
  /// width, and a glyph a seller has to decode is one they decode every time.
  row,
}
