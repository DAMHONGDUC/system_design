import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class SdNavigationDestinationV4 {
  const SdNavigationDestinationV4({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class SdBottomNavigationV4 extends StatelessWidget {
  const SdBottomNavigationV4({
    required this.currentIndex,
    required this.destinations,
    required this.onSelected,
    super.key,
  });

  final int currentIndex;
  final List<SdNavigationDestinationV4> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: NavigationBar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: 0.78),
          selectedIndex: currentIndex,
          onDestinationSelected: onSelected,
          destinations: destinations
              .map(
                (SdNavigationDestinationV4 item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
