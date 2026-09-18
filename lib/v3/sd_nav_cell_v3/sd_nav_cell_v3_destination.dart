part of 'sd_nav_cell_v3.dart';

/// One destination in the shell's navigation chrome.
///
/// A value type rather than a widget so the chrome controls every dimension —
/// a destination that brought its own `Icon` would size itself, and neither
/// the pill's row nor the rail's column would line up.
@immutable
class SdNavDestinationV3 {
  const SdNavDestinationV3({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;

  /// Shown when this destination is current. Usually the filled variant of
  /// [icon] — weight is a second signal alongside colour, which colour alone
  /// must never be.
  final IconData? selectedIcon;

  /// **Required on every destination, and the semantics label of every
  /// cell.** The chrome is intentionally glyph-only, but it is not icon-only
  /// to a screen reader.
  final String label;
}
