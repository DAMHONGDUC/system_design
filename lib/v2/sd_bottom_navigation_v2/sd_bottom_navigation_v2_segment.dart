part of 'sd_bottom_navigation_v2.dart';

/// One equal-width segment of the glyph-only bar.
///
/// **The tap target is the whole cell**, full height and a full share of the
/// width — the thumb's inset is paint, never a gap in what can be hit
/// (WIDGET_RULES § 6).
class _NavSegment extends StatelessWidget {
  const _NavSegment({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  /// Solid when selected, outline when not — colour is never the only signal
  /// (hard rule 3), and this is the second one.
  static const double _selectedFill = 1;
  static const double _unselectedFill = 0;

  /// Faster than the thumb's slide, so the glyph has settled by the time the
  /// thumb arrives under it rather than the other way round.
  static const Duration _fillDuration = Duration(milliseconds: 200);

  final SdNavDestinationV2 destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color colour = selected
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;
    final IconData glyph = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      // The glyph carries no text; the label above is the whole announcement.
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: _fillDuration,
            curve: Curves.easeOutCubic,
            tween: Tween<double>(
              end: selected ? _selectedFill : _unselectedFill,
            ),
            builder: (BuildContext context, double fill, Widget? _) => SdIconV2(
              icon: glyph,
              size: SdSpacingConstant.r26,
              color: colour,
              fill: fill,
            ),
          ),
        ),
      ),
    );
  }
}
