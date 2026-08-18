import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// A placeholder in the shape of the thing that has not arrived yet.
///
/// **A shaped placeholder is not a second spinner, it is a different
/// answer.** A spinner says "waiting"; a skeleton says "waiting, and here is
/// how much of the screen this will fill" — so the layout does not jump when
/// the content lands. Use it where the shape is known in advance (a card, a
/// list of rows, a chart) and keep the spinner for a wait whose result has no
/// shape yet, or for an action the user just started.
///
/// **It does not move. Not a shimmer, and not a pulse either.** Rule 6 of
/// this package: nothing flashes, strobes or pulses, because the product this
/// generation renders is for photophobic users. That rules out the shimmer
/// every other design system reaches for — a specular band sweeping across
/// the screen is the clearest possible case of it — and it rules out the
/// gentle breathing fade that looks like the safe compromise, because a
/// placeholder animating on a slow loop is a light source moving in the
/// user's periphery for as long as the network takes.
///
/// What it has instead is the shape, which was the useful half all along: a
/// still block at [SdThemeV2.surfaceElevated] reserves the right space and
/// reads as "not yet", and the spinner the surface may also carry is what
/// says the app is still working.
class SdSkeletonV2 extends StatelessWidget {
  const SdSkeletonV2({
    required this.height,
    this.width,
    this.radius,
    super.key,
  });

  /// One line of body text, at [fraction] of the available width.
  ///
  /// A fraction rather than a number: placeholder lines are ragged like real
  /// text, and a caller that typed widths would be inventing a paragraph.
  static Widget line({double fraction = 1, double? height, Key? key}) =>
      SdSkeletonLineV2(fraction: fraction, height: height, key: key);

  /// What a line of body text costs, so a stack of them is the height of the
  /// paragraph it stands in for.
  static double get lineHeight => SdSpacingConstant.h14;

  /// The gap a caller should leave between two placeholder lines.
  static double get lineGap => SdSpacingConstant.h8;

  final double height;

  /// Null fills whatever width the parent gives.
  final double? width;

  /// Defaults to half the height, capped at the card radius — which is what
  /// makes a stack of lines read as text and a tall block read as a card.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.sdTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(
          radius ?? (height / 2).clamp(0, SdSpacingConstant.r16),
        ),
      ),
      child: SizedBox(height: height, width: width),
    );
  }
}

/// One placeholder line at a fraction of its parent's width. Reached through
/// [SdSkeletonV2.line]; a real widget class rather than a `_build` helper so
/// Flutter can scope its rebuild.
class SdSkeletonLineV2 extends StatelessWidget {
  const SdSkeletonLineV2({this.fraction = 1, this.height, super.key});

  final double fraction;
  final double? height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: AlignmentDirectional.centerStart,
    widthFactor: fraction.clamp(0, 1),
    child: SdSkeletonV2(height: height ?? SdSkeletonV2.lineHeight),
  );
}
