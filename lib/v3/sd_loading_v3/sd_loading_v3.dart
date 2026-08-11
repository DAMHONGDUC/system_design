import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';

/// The one loading indicator in v3.
///
/// Deliberately plain, and deliberately the only one: a system with a spinner
/// here and a shimmer there tells the user two different things about the
/// same wait. Anything that needs a *shaped* placeholder (a list of item
/// cards fading in) builds a skeleton out of `SdCardV3` and
/// `SdThemeV3.surfaceSunken` instead — that is composition, not a second
/// loading widget.
class SdLoadingV3 extends StatelessWidget {
  const SdLoadingV3({this.size, this.color, super.key});

  /// Inline size — beside a label, inside a row.
  static double get inlineSize => SdSpacingConstant.r16;

  /// The size a page-filling spinner takes.
  static double get pageSize => SdSpacingConstant.r28;

  final double? size;
  final Color? color;

  /// A spinner centred in whatever space it is given — the body of a screen
  /// that has not loaded yet.
  static Widget page({Color? color}) => SdLoadingV3Page(color: color);

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size ?? inlineSize,
    child: CircularProgressIndicator(
      strokeWidth: SdSpacingConstant.w2,
      color: color ?? context.colorScheme3.primary,
    ),
  );
}

/// A centred [SdLoadingV3] at [SdLoadingV3.pageSize]. Reached through
/// `SdLoadingV3.page()`; a real widget class rather than a `_build` helper so
/// Flutter can scope its rebuild.
class SdLoadingV3Page extends StatelessWidget {
  const SdLoadingV3Page({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Center(child: SdLoadingV3(size: SdLoadingV3.pageSize, color: color));
}
