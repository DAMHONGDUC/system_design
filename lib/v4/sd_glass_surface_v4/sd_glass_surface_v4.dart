import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../core/sd_spacing_constant.dart';

final class SdGlassV4 {
  static bool? _debugOverride;

  @visibleForTesting
  static set debugSupported(bool? value) => _debugOverride = value;

  static bool get isSupported =>
      _debugOverride ?? ImageFilter.isShaderFilterSupported;
}

class SdGlassSurfaceV4 extends StatelessWidget {
  const SdGlassSurfaceV4({
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding,
    this.radius,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsets? padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double resolvedRadius = radius ?? SdSpacingConstant.r16;
    final BorderRadius borderRadius = BorderRadius.circular(resolvedRadius);
    final Widget content = Padding(
      padding: padding ?? EdgeInsets.all(SdSpacingConstant.r16),
      child: child,
    );
    final Widget interactive = onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: content,
            ),
          );
    final LiquidGlassSettings settings = LiquidGlassSettings(
      glassColor: colors.surface.withValues(alpha: 0.32),
      thickness: 18,
      refractiveIndex: 1.32,
      blur: 12,
      lightIntensity: 0.85,
      ambientStrength: 0.45,
      chromaticAberration: 0,
      saturation: 1.1,
    );

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: colors.outlineVariant),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: SdSpacingConstant.r16,
              offset: Offset(0, SdSpacingConstant.h8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: SdGlassV4.isSupported
              ? LiquidGlass.withOwnLayer(
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: resolvedRadius,
                  ),
                  settings: settings,
                  glassContainsChild: false,
                  child: interactive,
                )
              : ColoredBox(
                  color: colors.surfaceContainerLow.withValues(alpha: 0.94),
                  child: interactive,
                ),
        ),
      ),
    );
  }
}
