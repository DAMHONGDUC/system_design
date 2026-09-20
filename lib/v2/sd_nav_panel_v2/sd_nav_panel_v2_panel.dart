part of 'sd_nav_panel_v2.dart';

/// The column the panel occupies, animating between a fifth of the window and
/// nothing.
///
/// **The contents are laid out at full width the whole way and clipped.**
/// Reflowing them as the width travels is what produces overflow stripes on a
/// reversed animation, so the child is given the panel's full width by an
/// [OverflowBox] and the box around it does the moving.
class _PanelRegion extends StatelessWidget {
  const _PanelRegion({
    required this.width,
    required this.progress,
    required this.isExpanded,
    required this.child,
  });

  final double width;
  final double progress;
  final bool isExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: SdNavPanelV2.panelRegionKey,
    width: width * progress,
    child: ClipRect(
      child: OverflowBox(
        alignment: AlignmentDirectional.centerStart,
        minWidth: width,
        maxWidth: width,
        // A panel still painting at 3 wide must not be tappable and must not be
        // read out; collapsed, it is not built at all.
        child: progress > 0
            ? IgnorePointer(
                ignoring: !isExpanded,
                child: ExcludeSemantics(excluding: !isExpanded, child: child),
              )
            : null,
      ),
    ),
  );
}

/// The panel's own surface: the close control, then the destinations.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.isExpanded,
    required this.collapseLabel,
    required this.onCollapse,
  });

  final List<SdNavDestinationV2> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// False while the panel is still painting its way out. It keeps the key off
  /// the toggle in that window: the app bar has already claimed the control by
  /// then, and two nodes under one key is a finder that cannot say which.
  final bool isExpanded;

  final String collapseLabel;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: SdNavPanelV2.panelSurfaceKey,
    color: context.colorScheme.surface,
    child: SafeArea(
      // The trailing edge is the content's, not the window's — there is no
      // device inset there to pay.
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // One toolbar tall, so the control sits where the same control sits
          // in the app bar and does not jump as the panel closes. Separate from
          // the destinations so it never reads as a sixth tab.
          SizedBox(
            height: SdAppBarV2.toolbarHeight,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: SdContentPaddingV2.horizontal,
                ),
                child: SdNavPanelToggleV2(
                  key: isExpanded ? SdNavPanelToggleV2.toggleKey : null,
                  expanded: isExpanded,
                  label: collapseLabel,
                  onPressed: onCollapse,
                ),
              ),
            ),
          ),
          // Scrollable so the destinations stay reachable in a window short
          // enough that the header and five rows do not fit.
          Expanded(
            child: SingleChildScrollView(
              child: _Destinations(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// One row per destination, with the capsule sliding behind them.
class _Destinations extends StatelessWidget {
  const _Destinations({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SdNavDestinationV2> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>[
      for (final SdNavDestinationV2 destination in destinations)
        destination.label,
    ];

    return SizedBox(
      width: double.infinity,
      height: SdContentPaddingV2.navPanelRowHeight * destinations.length,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _SelectedCapsule(
            count: destinations.length,
            selectedIndex: selectedIndex,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final (int index, SdNavDestinationV2 destination)
                  in destinations.indexed)
                Expanded(
                  child: SdNavSegmentV2(
                    destination: destination,
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                    shape: SdNavSegmentShapeV2.row,
                    labelPeers: labels,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The tinted capsule that marks the current tab and slides down to the next.
///
/// **Always one row tall**, for the reason the pill's thumb is always one
/// segment wide: every destination is the same size, so a capsule that grew
/// would be tracking something the rows do not say.
class _SelectedCapsule extends StatelessWidget {
  const _SelectedCapsule({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => AnimatedAlign(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : SdNavPanelV2._travel,
    curve: SdNavPanelV2._curve,
    // Alignment.y spans -1 (top) … 1 (bottom).
    alignment: AlignmentDirectional(
      0,
      count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
    ),
    child: FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1 / count,
      child: Padding(
        padding: SdContentPaddingV2.navPanelCapsuleInset,
        child: DecoratedBox(
          key: SdNavPanelV2.selectedCapsuleKey,
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withValues(
              alpha: SdNavPanelV2.selectedCapsuleOpacity,
            ),
            borderRadius: BorderRadius.circular(
              SdContentPaddingV2.navPanelCapsuleRadius,
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}
