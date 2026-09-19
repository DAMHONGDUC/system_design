part of 'sd_nav_panel_v3.dart';

/// Keep the control reachable even when a keyboard leaves little height.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.isExpanded,
    required this.onToggle,
    required this.toggleLabel,
  });

  final List<SdNavDestinationV3> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String toggleLabel;

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: SdNavPanelV3.panelSurfaceKey,
    color: context.colorScheme3.surface,
    child: SafeArea(
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: _PanelToggle(
              key: isExpanded ? SdNavPanelV3.toggleKey : null,
              expanded: isExpanded,
              label: toggleLabel,
              onPressed: onToggle,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _PanelSurface(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
                shape: SdNavCellShapeV3.row,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PanelToggle extends StatelessWidget {
  const _PanelToggle({
    required this.expanded,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final bool expanded;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    expanded: expanded,
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: SdIconV3(Symbols.menu_),
    ),
  );
}

class _PanelSurface extends StatelessWidget {
  const _PanelSurface({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.shape,
  });

  final List<SdNavDestinationV3> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final SdNavCellShapeV3 shape;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: SdContentPaddingV3.panelRowHeight * destinations.length,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _SelectedCapsule(
          count: destinations.length,
          selectedIndex: selectedIndex,
        ),
        Column(
          children: <Widget>[
            for (int i = 0; i < destinations.length; i++)
              Expanded(
                child: SdNavCellV3(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                  shape: shape,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

/// The tinted thumb, sliding down the panel instead of across the bar.
class _SelectedCapsule extends StatelessWidget {
  const _SelectedCapsule({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => AnimatedAlign(
    duration: SdMotionV3.normal,
    curve: SdMotionV3.emphasized,
    alignment: AlignmentDirectional(
      0,
      count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
    ),
    child: FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1 / count,
      child: Padding(
        padding: SdContentPaddingV3.selectedTabInset,
        child: DecoratedBox(
          key: SdNavPanelV3.selectedCapsuleKey,
          decoration: BoxDecoration(
            color: context.colorScheme3.primary.withValues(
              alpha: SdGlassV3.selectedThumbOpacity,
            ),
            borderRadius: BorderRadius.circular(
              SdContentPaddingV3.selectedTabRadius,
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}
