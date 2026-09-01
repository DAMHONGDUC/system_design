import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v4/sd_content_padding_v4.dart';
import '../sd_glass_surface_v4/sd_glass_surface_v4.dart';

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

/// Floating glass navigation bar. Sizes itself to its content so it can sit in
/// a `Scaffold.bottomNavigationBar` slot without stealing height from the body.
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
    return Padding(
      padding: EdgeInsets.only(
        left: SdSpacingConstant.w16,
        right: SdSpacingConstant.w16,
        bottom: SdContentPaddingV4.navBarOffset(context),
      ),
      child: SdGlassSurfaceV4(
        padding: EdgeInsets.symmetric(vertical: SdSpacingConstant.h6),
        radius: SdSpacingConstant.r24,
        child: Row(
          children: <Widget>[
            for (int index = 0; index < destinations.length; index++)
              Expanded(
                child: _NavigationItemV4(
                  destination: destinations[index],
                  selected: index == currentIndex,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItemV4 extends StatelessWidget {
  const _NavigationItemV4({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final SdNavigationDestinationV4 destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground = selected
        ? colors.primary
        : colors.onSurfaceVariant;

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: SdSpacingConstant.h48),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SdSpacingConstant.w4,
                  vertical: SdSpacingConstant.h6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      selected ? destination.selectedIcon : destination.icon,
                      color: foreground,
                      size: SdSpacingConstant.r22,
                    ),
                    SizedBox(height: SdSpacingConstant.h2),
                    Text(
                      destination.label,
                      style: textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
