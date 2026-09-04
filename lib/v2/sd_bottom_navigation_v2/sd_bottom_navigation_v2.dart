import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_floating_bar_scope_v2/sd_floating_bar_scope_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';
import '../sd_pop_scale_v2/sd_pop_scale_v2.dart';

part 'sd_bottom_navigation_v2_bar.dart';
part 'sd_bottom_navigation_v2_segment.dart';

/// One destination in [SdBottomNavigationV2].
///
/// A value type rather than a widget so the bar controls every dimension —
/// a destination that brought its own `Icon` would size itself and the row
/// would stop lining up.
@immutable
class SdNavDestinationV2 {
  const SdNavDestinationV2({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;

  /// Shown when this destination is current. Leave null for a Material
  /// Symbols glyph: [SdIconV2] fills the same glyph instead, which is one
  /// name rather than two. Set it only where the selected state is a
  /// genuinely different drawing.
  final IconData? selectedIcon;

  /// **Required on every destination, and the semantics label of every
  /// segment.** The bar is deliberately glyph-only, but it is not icon-only
  /// to a screen reader.
  final String label;
}

/// The complete frame for a glyph-only floating bottom navigation.
///
/// The host supplies destinations and changes its own selected content. This
/// widget owns the glass pill, the sliding thumb and the adjacent-tab swipe,
/// so every screen behind it gets the same interaction and the same
/// clearance.
///
/// **A plain [Scaffold], not `SdScaffoldV2`** — the shell has no app bar of
/// its own; each tab screen brings its own `SdScaffoldV2` and its own title.
/// [Scaffold.extendBody] is unconditional here: the pill stays glass on every
/// engine (`SdGlassV2` degrades that one surface to `FakeGlass` by itself),
/// so its footprint is layout on every engine too. Screens behind it pad by
/// `SdContentPaddingV2.bottom(floatingNav: true)`.
class SdBottomNavigationV2 extends StatefulWidget {
  const SdBottomNavigationV2({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(destinations.length > 0, 'A nav bar needs a destination.'),
       assert(
         selectedIndex >= 0 && selectedIndex < destinations.length,
         'selectedIndex is out of range for destinations.',
       );

  final Widget body;
  final List<SdNavDestinationV2> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// A deliberate swipe, large enough that a slightly diagonal vertical drag
  /// does not switch tabs after winning the horizontal gesture arena.
  static double get swipeDistance => SdSpacingConstant.w48;

  @visibleForTesting
  static const Key swipeSurfaceKey = Key('sd-bottom-navigation-v2-swipe');

  @override
  State<SdBottomNavigationV2> createState() => _SdBottomNavigationV2State();
}

class _SdBottomNavigationV2State extends State<SdBottomNavigationV2> {
  double _dragDistance = 0;

  void _startSwipe(DragStartDetails _) => _dragDistance = 0;

  void _updateSwipe(DragUpdateDetails details) {
    _dragDistance += details.primaryDelta ?? 0;
  }

  void _cancelSwipe() => _dragDistance = 0;

  void _finishSwipe(DragEndDetails _) {
    final double distance = _dragDistance;
    _dragDistance = 0;

    if (distance.abs() < SdBottomNavigationV2.swipeDistance) return;

    // Dragging left (negative) walks forward through the tabs.
    final int direction = distance < 0 ? 1 : -1;
    final int nextIndex = widget.selectedIndex + direction;

    if (nextIndex < 0 || nextIndex >= widget.destinations.length) return;

    widget.onSelected(nextIndex);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // Lets the body flow behind the pill so it refracts through the glass.
    extendBody: true,
    // Tells anything drawn over the app — a snackbar goes into the root
    // overlay, above the shell — that the pill is down there to clear.
    body: SdFloatingBarScopeV2(
      child: GestureDetector(
        key: SdBottomNavigationV2.swipeSurfaceKey,
        // Translucent so a scrollable, a slider or a chart underneath claims
        // its own horizontal drag first; only the misses reach this.
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        onHorizontalDragStart: _startSwipe,
        onHorizontalDragUpdate: _updateSwipe,
        onHorizontalDragCancel: _cancelSwipe,
        onHorizontalDragEnd: _finishSwipe,
        child: widget.body,
      ),
    ),
    bottomNavigationBar: _GlassNavBar(
      destinations: widget.destinations,
      selectedIndex: widget.selectedIndex,
      onSelected: widget.onSelected,
    ),
  );
}
