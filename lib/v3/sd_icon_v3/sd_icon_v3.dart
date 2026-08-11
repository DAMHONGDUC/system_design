import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';

/// The one icon widget in v3 — feature code never uses a raw [Icon].
///
/// Two things it guarantees that [Icon] does not:
///
/// 1. **It always resolves to a concrete size.** A bare [Icon] inherits from
///    the ambient [IconTheme], so the same glyph comes out at different sizes
///    in a button, an app bar and a list row depending on what happened to
///    wrap it. Here [size] defaults to [defaultSize] and is never null.
/// 2. **It always resolves to a concrete colour** — [SdThemeV3.textPrimary]
///    when a call site says nothing, rather than whatever the ambient theme
///    last set.
///
/// Pass an `SdSpacingConstant.r*` for [size], never a raw number.
class SdIconV3 extends StatelessWidget {
  const SdIconV3(this.icon, {this.size, this.color, this.semanticLabel, super.key});

  /// The size an icon takes when nothing asks for another — a list row's
  /// leading glyph, an inline affordance.
  static double get defaultSize => SdSpacingConstant.r20;

  /// A glyph that is the point of what it sits in: an empty state's mark, a
  /// large status indicator.
  static double get largeSize => SdSpacingConstant.r28;

  /// A glyph beside text it must not outweigh — a chip's leading mark, a
  /// caption's clock.
  static double get smallSize => SdSpacingConstant.r16;

  final IconData icon;
  final double? size;
  final Color? color;

  /// Set this only when the icon carries meaning no nearby text already
  /// gives. A decorative glyph beside its own label is noise to a screen
  /// reader, and leaving this null excludes it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Icon(
    icon,
    size: size ?? defaultSize,
    color: color ?? context.sdTheme3.textPrimary,
    semanticLabel: semanticLabel,
  );
}
