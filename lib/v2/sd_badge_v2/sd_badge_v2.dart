import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// A badge marking "there is something here", parked on the corner of
/// [child] — an app-bar icon, a tab, a row.
///
/// [count] chooses the look: null draws a plain dot, a number draws the
/// number. A dot answers "is there anything?" and a count answers "how
/// many" — use the dot wherever the number would not change what the user
/// does, which is why a list row gets a dot and the app-bar icon gets a
/// count.
///
/// The ring is what keeps it legible: dropped straight onto a frosted app bar
/// the accent alone can land on any colour behind it, so the badge carries a
/// ring of the surface it sits on and reads as separate at every background.
///
/// Digits are the one text this package renders without being handed it —
/// numerals are not copy, and making every call site format "how many" would
/// be the same two lines everywhere.
class SdBadgeV2 extends StatelessWidget {
  const SdBadgeV2({
    required this.child,
    required this.showing,
    this.count,
    this.color,
    super.key,
  });

  static const double ringWidth = 2;

  /// Above this the badge stops counting and says so, rather than growing
  /// wide enough to cover the icon it sits on.
  static const int maxCount = 99;

  final Widget child;

  /// Nothing is drawn when false — the badge never occupies space it is not
  /// using, so the icon under it does not shift when it appears.
  final bool showing;

  /// Null draws a dot. A number draws the number; 0 draws nothing at all,
  /// since "none" is what the absence of a badge already says.
  final int? count;

  /// Defaults to the theme's primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final int? value = count;

    if (!showing || value == 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        PositionedDirectional(
          top: -ringWidth,
          end: -ringWidth,
          child: value == null
              ? _Dot(color: color)
              : _Count(value: value, color: color),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final double diameter = SdSpacingConstant.r8 + SdBadgeV2.ringWidth * 2;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.sdTheme.background,
          width: SdBadgeV2.ringWidth,
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, this.color});

  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? context.colorScheme.primary;
    final String label = value > SdBadgeV2.maxCount
        ? '${SdBadgeV2.maxCount}+'
        : '$value';

    return Container(
      // A minimum width, not a fixed one: one digit stays a circle and more
      // digits widen it into a stadium instead of being clipped.
      constraints: BoxConstraints(minWidth: SdSpacingConstant.r20),
      height: SdSpacingConstant.r20,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: SdSpacingConstant.w4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
        border: Border.all(
          color: context.sdTheme.background,
          width: SdBadgeV2.ringWidth,
        ),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall!.semiBold.copyWith(
          color: context.colorScheme.onPrimary,
        ),
        maxLines: 1,
      ),
    );
  }
}
