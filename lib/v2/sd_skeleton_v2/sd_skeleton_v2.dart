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
/// **It shimmers** (owner's call, replacing the still block this used to be).
/// A block that never moves reads as content the app has finished drawing
/// badly, not as content on its way; the sweep is what says the wait is still
/// running without a second spinner on top of the shape. It is the one
/// looping animation rule 6 of this package allows, and it is kept as quiet
/// as a sweep can be: [_sweep] long, one band at [_highlightAlpha] over
/// [SdThemeV2.surfaceElevated], no white and no opacity flash — the band is a
/// lighter grey crossing a dark one.
///
/// **The OS switch wins.** With "Reduce Motion" on, [MediaQuery]'s
/// `disableAnimations` is true and this renders the still block instead — the
/// photophobic user who turned motion off in Settings does not have to find a
/// second switch in this app.
///
/// **Every skeleton is a rectangle at [radius] (8), and there is no way to
/// ask for another one** (owner's rule). One shape means a screen's
/// placeholders read as one loading state rather than as a pile of unrelated
/// blocks — and it is deliberately not the shape of the thing underneath: a
/// pill for a line and a card radius for a card had every skeleton quietly
/// impersonating a different component, which is how a placeholder starts
/// being mistaken for content. Not a circle either, avatar or not.
class SdSkeletonV2 extends StatefulWidget {
  const SdSkeletonV2({required this.height, this.width, super.key});

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

  /// The one corner every skeleton wears. Not a prop — see the class doc.
  static double get radius => SdSpacingConstant.r8;

  /// One pass of the band across the block.
  ///
  /// Longer than the 400ms rule 6 caps a micro-interaction at, and on purpose:
  /// that cap exists so a transition cannot flash, and a sweep this slow is
  /// the opposite failure mode — under ~1s the band starts reading as a
  /// blink.
  static const Duration _sweep = Duration(milliseconds: 1400);

  /// How much lighter the band is than the block it crosses. Small enough
  /// that the block still reads as one surface, large enough to see on an OLED
  /// panel at low brightness — which is the screen this system is drawn for.
  static const double _highlightAlpha = 0.08;

  final double height;

  /// Null fills whatever width the parent gives.
  final double? width;

  @override
  State<SdSkeletonV2> createState() => _SdSkeletonV2State();
}

class _SdSkeletonV2State extends State<SdSkeletonV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SdSkeletonV2._sweep,
  );

  /// Reduce Motion, read once per dependency change rather than per frame.
  bool _still = false;

  /// Started here rather than in `initState`, because whether it should run at
  /// all is a MediaQuery answer — and stopped rather than left ticking, so a
  /// user who turned motion off is not paying for a repaint a frame.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);

    if (_still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = context.sdTheme.surfaceElevated;
    final BorderRadius corner = BorderRadius.circular(SdSkeletonV2.radius);
    final Widget box = SizedBox(height: widget.height, width: widget.width);

    if (_still) {
      return DecoratedBox(
        decoration: BoxDecoration(color: base, borderRadius: corner),
        child: box,
      );
    }

    // Blended rather than laid over: a translucent white band would lighten
    // whatever sits behind a skeleton with a transparent parent, and the band
    // has to be one flat colour for the gradient to stay a gradient.
    final Color highlight = Color.alphaBlend(
      Colors.white.withValues(alpha: SdSkeletonV2._highlightAlpha),
      base,
    );

    return AnimatedBuilder(
      animation: _controller,
      // Built once and passed through: the size never changes, only the paint.
      child: box,
      builder: (BuildContext context, Widget? child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: corner,
          gradient: LinearGradient(
            colors: <Color>[base, highlight, base],
            transform: _SdSkeletonSweepV2(_controller.value),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Slides the whole gradient across the block, from fully off one edge to
/// fully off the other.
///
/// The band is off-screen at both ends of the travel, which is what lets the
/// controller `repeat()` without a visible jump at the wrap — a reversing
/// sweep would instead run the band back the way it came, and a placeholder
/// that rocks left and right is the "pulse" this system does not do.
@immutable
class _SdSkeletonSweepV2 extends GradientTransform {
  const _SdSkeletonSweepV2(this.progress);

  /// 0 → the gradient sits one full width to the left, 1 → one to the right.
  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (progress * 2 - 1), 0, 0);
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
