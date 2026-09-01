part of 'sd_search_header_v4.dart';

final class _SdSearchHeaderDelegateV4 extends SliverPersistentHeaderDelegate {
  const _SdSearchHeaderDelegateV4({
    required this.topPadding,
    required this.title,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.onChanged,
    required this.onSubmitted,
  });

  final double topPadding;
  final String title;
  final TextEditingController controller;
  final String label;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  double get _searchRow =>
      SdSearchHeaderMetricsV4.fieldGap +
      SdSearchHeaderMetricsV4.expandedFieldHeight;

  @override
  double get maxExtent =>
      topPadding + SdSearchHeaderMetricsV4.toolbarHeight + _searchRow;

  @override
  double get minExtent => topPadding + SdSearchHeaderMetricsV4.toolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double height = math.max(minExtent, maxExtent - shrinkOffset);
    final double progress = ((maxExtent - height) / _searchRow).clamp(0.0, 1.0);
    final double width = MediaQuery.sizeOf(context).width;
    final Rect fieldRect = Rect.lerp(
      _expandedField(width),
      _dockedField(width),
      progress,
    )!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Color.lerp(
              colorScheme.outlineVariant.withAlpha(0),
              colorScheme.outlineVariant,
              progress,
            )!,
            width: SdSpacingConstant.h1,
          ),
        ),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            _SdSearchHeaderTitleV4(
              title: title,
              top: topPadding,
              progress: progress,
            ),
            Positioned.fromRect(
              rect: fieldRect,
              child: _SdSearchHeaderFieldV4(
                controller: controller,
                label: label,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Rect _expandedField(double width) => Rect.fromLTWH(
    SdContentPaddingV4.horizontal,
    topPadding +
        SdSearchHeaderMetricsV4.toolbarHeight +
        SdSearchHeaderMetricsV4.fieldGap,
    width - SdContentPaddingV4.horizontal * 2,
    SdSearchHeaderMetricsV4.expandedFieldHeight,
  );

  Rect _dockedField(double width) => Rect.fromLTWH(
    SdContentPaddingV4.horizontal,
    topPadding +
        (SdSearchHeaderMetricsV4.toolbarHeight -
                SdSearchHeaderMetricsV4.dockedFieldHeight) /
            2,
    width - SdContentPaddingV4.horizontal * 2,
    SdSearchHeaderMetricsV4.dockedFieldHeight,
  );

  @override
  bool shouldRebuild(covariant _SdSearchHeaderDelegateV4 oldDelegate) =>
      oldDelegate.topPadding != topPadding ||
      oldDelegate.title != title ||
      oldDelegate.controller != controller ||
      oldDelegate.label != label ||
      oldDelegate.prefixIcon != prefixIcon ||
      oldDelegate.suffixIcon != suffixIcon ||
      oldDelegate.onChanged != onChanged ||
      oldDelegate.onSubmitted != onSubmitted;
}

final class _SdSearchHeaderTitleV4 extends StatelessWidget {
  const _SdSearchHeaderTitleV4({
    required this.title,
    required this.top,
    required this.progress,
  });

  final String title;
  final double top;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final double opacity = (1 - progress * 2).clamp(0.0, 1.0);

    return Positioned(
      top: top,
      left: SdContentPaddingV4.horizontal,
      right: SdContentPaddingV4.horizontal,
      height: SdSearchHeaderMetricsV4.toolbarHeight,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

final class _SdSearchHeaderFieldV4 extends StatelessWidget {
  const _SdSearchHeaderFieldV4({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      textAlignVertical: TextAlignVertical.center,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: (PointerDownEvent event) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SdSpacingConstant.w16,
          vertical: SdSpacingConstant.h8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: SdSpacingConstant.w2,
          ),
        ),
      ),
    );
  }
}
