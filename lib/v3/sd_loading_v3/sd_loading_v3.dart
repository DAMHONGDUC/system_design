import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';

/// The one loading indicator in v3.
///
/// Deliberately the only one: a system with a spinner here and a shimmer there
/// tells the user two different things about the same wait. Anything that
/// needs a *shaped* placeholder (a list of item cards fading in) builds a
/// skeleton out of `SdCardV3` and `SdThemeV3.surfaceSunken` instead — that is
/// composition, not a second loading widget.
///
/// **It has two sizes and they draw differently, which is one look and not
/// two.** A wait the user is watching — a screen with nothing else on it — is
/// the newton's cradle; a wait happening inside something they are already
/// looking at — a button, a row — is the ring. The cradle at
/// [SdLoadingV3.inlineSize] would be four dots of under two points, which is a
/// smudge rather than an animation, and a ring filling an empty screen says
/// "stuck" rather than "working".
class SdLoadingV3 extends StatelessWidget {
  const SdLoadingV3({this.size, this.color, super.key});

  /// Inline size — beside a label, inside a row.
  static double get inlineSize => SdSpacingConstant.r16;

  /// The box the page-filling animation is drawn in.
  ///
  /// The cradle scales everything off it — its dots are a tenth of it — so
  /// this is the number that decides whether the balls read from arm's length.
  static double get pageSize => SdSpacingConstant.r88;

  final double? size;
  final Color? color;

  /// The animation centred in whatever space it is given — the body of a
  /// screen that has not loaded yet.
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

/// A centred newton's cradle at [SdLoadingV3.pageSize]. Reached through
/// `SdLoadingV3.page()`; a real widget class rather than a `_build` helper so
/// Flutter can scope its rebuild.
class SdLoadingV3Page extends StatelessWidget {
  const SdLoadingV3Page({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    child: LoadingAnimationWidget.newtonCradle(
      color: color ?? context.colorScheme3.primary,
      size: SdLoadingV3.pageSize,
    ),
  );
}
