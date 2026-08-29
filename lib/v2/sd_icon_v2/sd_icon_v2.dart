import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/sd_spacing_constant.dart';

/// The kind of source [SdIconV2] should render.
enum SdIconVariantV2 {
  icon,
  svgAsset,
  svgNetwork,
  imageAsset,
  imageNetwork,
  imageMemory,
}

/// The app's only icon widget — every icon renders through this so sizing
/// stays consistent across the app (hard rule: no raw [Icon]/[SvgPicture]/
/// [Image] in feature or core code, only here).
///
/// [variant] decides which field is actually used to render:
/// - [SdIconVariantV2.icon] → [icon]
/// - [SdIconVariantV2.svgAsset] / [imageAsset] → [source] (asset path)
/// - [SdIconVariantV2.svgNetwork] / [imageNetwork] → [source] (url)
/// - [SdIconVariantV2.imageMemory] → [bytes]
///
/// [size] always resolves to a concrete value: it defaults to
/// [SdSpacingConstant.r24] (Material's 24, run through screenutil) so every
/// icon has an explicit size rather than inheriting an ambient one. [color]
/// falls back to the surrounding [IconTheme] when null (ignored for raster
/// images unless [applyColorToImage] is true).
///
/// [fill] drives the fill axis of a variable icon font (Material Symbols),
/// where a filled and an outlined glyph are one icon at two fill values
/// rather than two icons. 0 is the outline, 1 is solid, and anything between
/// is how a selected tab animates. Ignored by static fonts and by every
/// image variant.
///
/// [hasPadding] wraps the rendered icon with [SdSpacingConstant.r8] padding
/// on all sides — useful for giving tappable icons a larger hit area without
/// affecting the visual icon size itself.
class SdIconV2 extends StatelessWidget {
  const SdIconV2({
    this.icon,
    this.source,
    this.bytes,
    this.size,
    this.color,
    this.fill,
    this.applyColorToImage = false,
    this.variant = SdIconVariantV2.icon,
    this.hasPadding = false,
    this.padding,
    super.key,
  });

  final SdIconVariantV2 variant;

  /// Required when [variant] == [SdIconVariantV2.icon].
  final IconData? icon;

  /// Asset path or network url. Required when [variant] is svgAsset,
  /// svgNetwork, imageAsset or imageNetwork.
  final String? source;

  /// Required when [variant] == [SdIconVariantV2.imageMemory].
  final Uint8List? bytes;

  final double? size;
  final Color? color;

  /// Fill axis of a variable icon font, 0 (outline) to 1 (solid).
  final double? fill;

  /// Whether to tint raster images (asset/network/memory) with [color].
  /// SVG and [Icon] are always tinted when [color] is set.
  final bool applyColorToImage;

  /// Whether to wrap the icon in padding. Ignored if [padding] is provided.
  final bool hasPadding;

  /// Custom padding around the icon. If set, this takes priority over
  /// [hasPadding] and is applied regardless of [hasPadding]'s value.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? SdSpacingConstant.r24;
    final resolvedColor = color ?? IconTheme.of(context).color;
    final colorFilter = resolvedColor == null
        ? null
        : ColorFilter.mode(resolvedColor, BlendMode.srcIn);

    final Widget child;
    switch (variant) {
      case SdIconVariantV2.icon:
        assert(
          icon != null,
          'SdIconV2: `icon` is required for SdIconVariantV2.icon',
        );
        child = Icon(
          icon,
          size: resolvedSize,
          color: resolvedColor,
          fill: fill,
        );

      case SdIconVariantV2.svgAsset:
        assert(
          source != null,
          'SdIconV2: `source` is required for SdIconVariantV2.svgAsset',
        );
        child = SvgPicture.asset(
          source!,
          width: resolvedSize,
          height: resolvedSize,
          colorFilter: colorFilter,
        );

      case SdIconVariantV2.svgNetwork:
        assert(
          source != null,
          'SdIconV2: `source` is required for SdIconVariantV2.svgNetwork',
        );
        child = SvgPicture.network(
          source!,
          width: resolvedSize,
          height: resolvedSize,
          colorFilter: colorFilter,
        );

      case SdIconVariantV2.imageAsset:
        assert(
          source != null,
          'SdIconV2: `source` is required for SdIconVariantV2.imageAsset',
        );
        child = _wrapColor(
          Image.asset(
            source!,
            width: resolvedSize,
            height: resolvedSize,
            fit: BoxFit.contain,
          ),
          resolvedColor,
        );

      case SdIconVariantV2.imageNetwork:
        assert(
          source != null,
          'SdIconV2: `source` is required for SdIconVariantV2.imageNetwork',
        );
        child = _wrapColor(
          Image.network(
            source!,
            width: resolvedSize,
            height: resolvedSize,
            fit: BoxFit.contain,
          ),
          resolvedColor,
        );

      case SdIconVariantV2.imageMemory:
        assert(
          bytes != null,
          'SdIconV2: `bytes` is required for SdIconVariantV2.imageMemory',
        );
        child = _wrapColor(
          Image.memory(
            bytes!,
            width: resolvedSize,
            height: resolvedSize,
            fit: BoxFit.contain,
          ),
          resolvedColor,
        );
    }

    final resolvedPadding =
        padding ?? (hasPadding ? EdgeInsets.all(SdSpacingConstant.r8) : null);

    if (resolvedPadding == null) return child;
    return Padding(padding: resolvedPadding, child: child);
  }

  /// Wraps a raster image with a [ColorFiltered] tint when
  /// [applyColorToImage] is enabled and a color is resolved.
  Widget _wrapColor(Widget image, Color? resolvedColor) {
    if (!applyColorToImage || resolvedColor == null) return image;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      child: image,
    );
  }
}
