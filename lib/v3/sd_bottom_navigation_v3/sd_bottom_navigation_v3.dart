import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_floating_bar_scope_v3/sd_floating_bar_scope_v3.dart';
import '../sd_glass_nav_bar_v3/sd_glass_nav_bar_v3.dart';
import '../sd_scaffold_v3/sd_scaffold_v3.dart';

/// The complete frame for a glyph-only floating bottom navigation.
///
/// The host supplies destinations and changes its own selected content. This
/// widget owns the glass frame and adjacent-tab swipe so every app gets the
/// same interaction and clearance.
class SdBottomNavigationV3 extends StatefulWidget {
  const SdBottomNavigationV3({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(destinations.length > 0),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  final Widget body;
  final List<SdNavDestinationV3> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// A deliberate swipe, large enough that a slightly diagonal vertical drag
  /// does not switch tabs after winning the horizontal gesture arena.
  static double get swipeDistance => SdSpacingConstant.w48;

  @visibleForTesting
  static const Key swipeSurfaceKey = Key('sd-bottom-navigation-swipe-surface');

  @override
  State<SdBottomNavigationV3> createState() => _SdBottomNavigationV3State();
}

class _SdBottomNavigationV3State extends State<SdBottomNavigationV3> {
  double _dragDistance = 0;

  void _startSwipe(DragStartDetails _) => _dragDistance = 0;

  void _updateSwipe(DragUpdateDetails details) {
    _dragDistance += details.primaryDelta ?? 0;
  }

  void _cancelSwipe() => _dragDistance = 0;

  void _finishSwipe(DragEndDetails _) {
    final double distance = _dragDistance;
    _dragDistance = 0;

    if (distance.abs() < SdBottomNavigationV3.swipeDistance) return;

    final int direction = distance < 0 ? 1 : -1;
    final int nextIndex = widget.selectedIndex + direction;

    if (nextIndex < 0 || nextIndex >= widget.destinations.length) return;

    widget.onSelected(nextIndex);
  }

  @override
  Widget build(BuildContext context) => SdScaffoldV3(
    extendBody: true,
    body: SdFloatingBarScopeV3(
      child: GestureDetector(
        key: SdBottomNavigationV3.swipeSurfaceKey,
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        onHorizontalDragStart: _startSwipe,
        onHorizontalDragUpdate: _updateSwipe,
        onHorizontalDragCancel: _cancelSwipe,
        onHorizontalDragEnd: _finishSwipe,
        child: widget.body,
      ),
    ),
    bottomNavigationBar: SdGlassNavBarV3(
      destinations: widget.destinations,
      selectedIndex: widget.selectedIndex,
      onSelected: widget.onSelected,
    ),
  );
}
