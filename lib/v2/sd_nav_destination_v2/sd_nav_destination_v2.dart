import 'package:flutter/widgets.dart';

/// One destination in the app's navigation chrome — `SdBottomNavigationV2` on
/// a phone, `SdNavigationRailV2` on a tablet.
///
/// A value type rather than a widget so the chrome controls every dimension —
/// a destination that brought its own `Icon` would size itself and the row
/// would stop lining up. Its own file rather than the bar's, because the rail
/// takes the same list and neither chrome owns the other.
@immutable
class SdNavDestinationV2 {
  const SdNavDestinationV2({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;

  /// Shown when this destination is current. Leave null for a Material
  /// Symbols glyph: `SdIconV2` fills the same glyph instead, which is one
  /// name rather than two. Set it only where the selected state is a
  /// genuinely different drawing.
  final IconData? selectedIcon;

  /// **Required on every destination, and the semantics label of every
  /// segment.** The chrome is deliberately glyph-only, but it is not icon-only
  /// to a screen reader.
  final String label;
}
