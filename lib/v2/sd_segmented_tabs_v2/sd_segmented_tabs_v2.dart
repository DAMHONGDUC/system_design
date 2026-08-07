import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// One segment of [SdSegmentedTabsV2]: what it is called, and how much is in
/// it.
class SdSegmentV2 {
  const SdSegmentV2({required this.label, this.count});

  /// Finished, localized. The package never builds copy.
  final String label;

  /// Drawn beside the label when set. Null leaves the segment bare — a count
  /// nobody needs is noise.
  final int? count;
}

/// A segmented control for switching between two or three views of the same
/// list: a track, and a thumb that slides under the selected segment.
///
/// Not Material's `TabBar`: that one is an underline and a page-swipe, which
/// reads as Android on an iOS-first app, and it wants a `TabController` for
/// what is one integer.
///
/// The count sits inside the segment rather than on its corner as an
/// `SdBadgeV2` would: a corner badge on a tab has to overhang something, and
/// in a track that means overhanging the neighbouring tab.
class SdSegmentedTabsV2 extends StatelessWidget {
  const SdSegmentedTabsV2({
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  static double get height => SdSpacingConstant.h42;

  final List<SdSegmentV2> segments;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: <Widget>[
          // Thumb: one segment wide, aligned to the selection. Calm 200ms
          // slide, no flash (WIDGET_RULES § 6).
          if (segments.length > 1)
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              // Alignment.x spans -1 (start) … 1 (end).
              alignment: AlignmentDirectional(
                -1 + 2 * selectedIndex / (segments.length - 1),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / segments.length,
                heightFactor: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SdSpacingConstant.w4,
                    vertical: SdSpacingConstant.h4,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.22,
                      ),
                      borderRadius: BorderRadius.circular(
                        SdSpacingConstant.r999,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Row(
            children: <Widget>[
              for (final (int index, SdSegmentV2 segment) in segments.indexed)
                Expanded(
                  child: _Segment(
                    segment: segment,
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final SdSegmentV2 segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color colour = selected
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;
    final int? count = segment.count;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                segment.label,
                style: selected
                    ? context.textTheme.labelLarge!.semiBold.copyWith(
                        color: colour,
                      )
                    : context.textTheme.labelLarge!.copyWith(color: colour),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null && count > 0) ...<Widget>[
              SizedBox(width: SdSpacingConstant.w6),
              _Count(value: count, selected: selected),
            ],
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.selected});

  final int value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color accent = selected
        ? context.colorScheme.primary
        : context.sdTheme.textSecondary;

    return Container(
      constraints: BoxConstraints(minWidth: SdSpacingConstant.r20),
      padding: EdgeInsets.symmetric(horizontal: SdSpacingConstant.w4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
      ),
      child: Text(
        '$value',
        style: context.textTheme.labelSmall!.semiBold.copyWith(color: accent),
        maxLines: 1,
      ),
    );
  }
}
