import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../core/sd_spacing_constant.dart';
import '../sd_badge_v2/sd_badge_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_liquid_glass_theme_v2/sd_liquid_glass_theme_v2.dart';
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
/// The count sits inside the segment as plain text, not on its corner as an
/// `SdBadgeV2` would: a corner badge on a tab has to overhang something, and
/// in a track that means overhanging the neighbouring tab.
///
/// **A segment's tap target is its whole cell of the track** — full height,
/// full share of the width, edge to edge with its neighbour, so the control
/// has no dead pixel anywhere inside its own bounds. The thumb's inset is
/// paint, never a gap in what can be hit.
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
    final Widget track = Container(
      height: height,
      decoration: BoxDecoration(
        // Opaque fill only when glass is off; the glass supplies the surface.
        color: SdGlassV2.isSupported
            ? null
            : context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        // Expand, or the row of segments takes only the height of its own
        // text and the Stack parks it at the top edge — the labels sit
        // against the top of the track instead of centred in it.
        fit: StackFit.expand,
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
            // Stretch, or each segment is only as tall as its own line of
            // text and the row centres it: the hit box came out ~20 of the
            // track's 42, and a tap near the top or bottom edge — which is
            // most of a thumb's spread — landed on nothing at all.
            crossAxisAlignment: CrossAxisAlignment.stretch,
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

    if (!SdGlassV2.isSupported) return track;
    // Frosted, and the thumb and labels paint crisply on top of it — the same
    // treatment the shell's nav pill gets.
    return LiquidGlass.withOwnLayer(
      settings: kChromeGlass,
      shape: LiquidRoundedSuperellipse(borderRadius: height / 2),
      clipBehavior: Clip.antiAlias,
      child: track,
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
    // Plain text, no tinted chip behind it: a filled pill next to a label
    // competes with the label for the same glance, and the number is the
    // quieter half of the pair.
    final Color colour = selected
        ? context.colorScheme.primary.withValues(alpha: 0.7)
        : context.sdTheme.textSecondary;
    // Capped, or a four-figure count pushes the label out of the segment.
    // Shares the badge's ceiling: one number for how high a count reads
    // anywhere in the system.
    final String label = value > SdBadgeV2.maxCount
        ? '${SdBadgeV2.maxCount}+'
        : '$value';

    return Text(
      label,
      style: context.textTheme.labelLarge!.copyWith(color: colour),
      maxLines: 1,
    );
  }
}
