import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// One word in a tinted pill: a state a row is in, stated where the eye
/// already is.
///
/// It is a *label*, never a control — nothing here takes an `onTap`. A pill
/// that can be pressed is a filter chip, and this system already has
/// `SdFilterPillV2` for that.
///
/// **The fill is the label's own colour at [fillOpacity], never a second
/// colour.** One hue per tag is what keeps a row of them reading as one
/// family, and it is why a caller passes a single [color] rather than a
/// foreground and a background that can drift apart.
class SdTagV2 extends StatelessWidget {
  const SdTagV2({required this.label, this.color, super.key});

  /// How much of [color] the fill carries. Low enough that the label stays
  /// the loudest thing in the pill, high enough that the pill has an edge
  /// without needing a border.
  static const double fillOpacity = 0.18;

  /// Already localized — this package renders no copy of its own.
  final String label;

  /// Label and fill together. Defaults to the theme's primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? context.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SdSpacingConstant.w8,
        vertical: SdSpacingConstant.h4,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: fillOpacity),
        borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall!.semiBold.copyWith(color: tint),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
