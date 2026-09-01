part of 'sd_search_header_v3.dart';

/// The geometry behind [SdSearchHeaderV3].
///
/// Everything is expressed as two rectangles and one number. `t` runs 0 → 1
/// as the header shrinks from [maxExtent] to [minExtent]; the search field is
/// `Rect.lerp`ed between where it sits expanded and where it docks, and the
/// title fades out over the first half of that travel.
///
/// The header draws the title, the field and the actions and nothing else — a
/// filter strip is its own widget in the body, never part of this chrome.
class _SdSearchHeaderDelegateV3 extends SliverPersistentHeaderDelegate {
  const _SdSearchHeaderDelegateV3({
    required this.topPadding,
    required this.title,
    required this.controller,
    required this.hint,
    required this.clearTooltip,
    required this.onChanged,
    required this.onSubmitted,
    required this.actions,
  });

  final double topPadding;
  final String title;
  final TextEditingController controller;
  final String hint;
  final String clearTooltip;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<SdAppBarActionV3> actions;

  /// The row the field lives in while expanded: the gap under the title row
  /// and the field itself. Exactly the height the header gives back on
  /// scroll, and nothing more — what sits below the header belongs to the
  /// body, and reserving space for it here is how one gap gets drawn twice.
  double get _searchRow =>
      SdSearchHeaderMetricsV3.fieldGap + SdSearchFieldV3.expandedHeight;

  @override
  double get maxExtent => topPadding + SdAppBarV3.toolbarHeight + _searchRow;

  @override
  double get minExtent => topPadding + SdAppBarV3.toolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // The child sizes itself; a delegate that returned `SizedBox.expand`
    // would stay at `maxExtent` and get its pinned strip clipped away.
    final double height = math.max(minExtent, maxExtent - shrinkOffset);
    final double t = ((maxExtent - height) / _searchRow).clamp(0.0, 1.0);
    final double width = MediaQuery.sizeOf(context).width;
    final double trailing = actions.isEmpty
        ? SdContentPaddingV3.horizontal
        : actions.length * SdAppBarActionV3.slot + SdSpacingConstant.w8 * 2;
    final Rect fieldRect = Rect.lerp(
      _expandedField(width),
      _collapsedField(width, trailing),
      t,
    )!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.sdTheme3.background,
        // The hairline arrives with the scroll, so a screen sitting at the
        // top is one clean surface and a scrolled one says where the chrome
        // ends. Painted, not laid out — it costs no height.
        border: Border(
          bottom: BorderSide(
            color: Color.lerp(
              context.sdTheme3.divider.withAlpha(0),
              context.sdTheme3.divider,
              t,
            )!,
            width: SdSpacingConstant.h1,
          ),
        ),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            _HeaderTitle(
              title: title,
              top: topPadding,
              left: SdContentPaddingV3.horizontal,
              right: trailing,
              t: t,
            ),
            _HeaderActions(actions: actions, top: topPadding),
            Positioned.fromRect(
              rect: fieldRect,
              child: SdSearchFieldV3(
                // The pill shrinks as it docks, so the field is told what it
                // is currently being drawn at rather than assuming.
                height: fieldRect.height,
                controller: controller,
                hint: hint,
                clearTooltip: clearTooltip,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full width, on its own row under the title — the app bar's own content,
  /// so it sits [SdContentPaddingV3.topGap] under it like any other.
  Rect _expandedField(double width) => Rect.fromLTWH(
    SdContentPaddingV3.horizontal,
    topPadding + SdAppBarV3.toolbarHeight + SdSearchHeaderMetricsV3.fieldGap,
    width - SdContentPaddingV3.horizontal * 2,
    SdSearchFieldV3.expandedHeight,
  );

  /// In the title's row, centred in it, stopping short of the actions.
  ///
  /// It docks at [SdSearchFieldV3.dockedHeight], which is shorter than the row
  /// on purpose — the leftover splits above and below as padding, so the pill
  /// sits *in* the bar rather than filling it edge to edge.
  Rect _collapsedField(double width, double trailing) => Rect.fromLTWH(
    SdContentPaddingV3.horizontal,
    topPadding + (SdAppBarV3.toolbarHeight - SdSearchFieldV3.dockedHeight) / 2,
    width - SdContentPaddingV3.horizontal - trailing,
    SdSearchFieldV3.dockedHeight,
  );

  @override
  bool shouldRebuild(covariant _SdSearchHeaderDelegateV3 oldDelegate) =>
      oldDelegate.topPadding != topPadding ||
      oldDelegate.title != title ||
      oldDelegate.controller != controller ||
      oldDelegate.hint != hint ||
      oldDelegate.clearTooltip != clearTooltip ||
      // The actions themselves, never their count: an action that changes
      // state — a filter glyph lighting up — is the same number of actions.
      !listEquals(oldDelegate.actions, actions);
}

/// The screen title, shown only while the header is expanded.
///
/// It fades over the first half of the travel and lifts slightly as it goes,
/// so the field arriving in its place reads as a replacement rather than as
/// two things briefly sharing a row.
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    required this.title,
    required this.top,
    required this.left,
    required this.right,
    required this.t,
  });

  final String title;
  final double top;
  final double left;
  final double right;
  final double t;

  @override
  Widget build(BuildContext context) {
    final double opacity = (1 - t * 2).clamp(0.0, 1.0);

    return Positioned(
      top: top,
      left: left,
      right: right,
      height: SdAppBarV3.toolbarHeight,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, -SdSpacingConstant.h8 * t),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: context.textTheme3.titleMedium!.semiBold3.copyWith(
                  color: context.sdTheme3.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The trailing icons, in the title's row and fixed there. They do not move,
/// fade or resize — the field docks *beside* them, and an action that shifted
/// as the page scrolled would be one a seller has to aim at twice.
class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.actions, required this.top});

  final List<SdAppBarActionV3> actions;
  final double top;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    right: SdSpacingConstant.w8,
    height: SdAppBarV3.toolbarHeight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final SdAppBarActionV3 action in actions)
          SdAppBarActionButtonV3(
            icon: action.icon,
            tooltip: action.tooltip,
            onPressed: action.onPressed,
            isActive: action.isActive,
          ),
      ],
    ),
  );
}
