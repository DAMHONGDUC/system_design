import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_pressable_scale_v2/sd_pressable_scale_v2.dart';

/// An action written as tappable text rather than a button.
///
/// For what must stay reachable without competing with the screen's primary
/// button — "Restore purchases" under a paywall CTA, a sign-in offer beneath
/// a purchase that never required one. Three stacked buttons read as three
/// offers of equal weight; one button and two of these read as one offer and
/// two ways out.
///
/// **It carries the accent colour, never the body colour.** Tappable text
/// that looks like prose is text nobody taps, and under a paywall that is a
/// restore path a reviewer cannot find.
///
/// **The padding is the tap target.** Without a button's own inset the hit
/// area would be exactly the height of the glyphs, which is a control only a
/// stylus can hit.
class SdTextActionV2 extends StatelessWidget {
  const SdTextActionV2({
    required this.label,
    required this.onTap,
    this.padding,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  /// Defaults to `SdSpacingConstant.h12` top and bottom — see the tap-target
  /// note above. Pass a smaller inset only where something else already
  /// spaces the row.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SdPressableScaleV2(
      onTap: onTap,
      child: Padding(
        padding:
            padding ?? EdgeInsets.symmetric(vertical: SdSpacingConstant.h12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
