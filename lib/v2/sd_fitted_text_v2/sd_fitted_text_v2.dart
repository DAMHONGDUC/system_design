import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

/// Text that shrinks to fit rather than ellipsing.
///
/// [peers] is for a label that changes while the frame around it does not — a
/// wizard's question in the app bar, a tab's title: sized on its own, each one
/// comes out a different size, and the size changing step to step reads as the
/// layout moving under the user. Pass the whole set and every one of them is
/// drawn at the size the longest can manage.
class SdFittedTextV2 extends StatelessWidget {
  const SdFittedTextV2(
    this.label, {
    super.key,
    required this.style,
    this.textAlign = TextAlign.center,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.stripNewlines = false,
    this.minFontSize,
    this.peers = const <String>[],
  });

  final String label;
  final TextStyle style;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;
  final bool stripNewlines;
  final double? minFontSize;

  /// The other labels this one takes turns with, [label] included or not.
  /// Empty (the default) sizes [label] alone, which is the plain behaviour.
  ///
  /// One line only: the shared size is measured off single-line widths, so a
  /// [maxLines] above 1 is asserted against rather than silently mismeasured.
  final List<String> peers;

  /// The ladder the shared size is snapped to, so a one-pixel difference in
  /// the widest label cannot show up as a visibly different size.
  static const double sharedStep = 0.5;

  String get _processedLabel =>
      stripNewlines ? label.replaceAll('\n', ' ') : label;

  double get _maxFontSize =>
      (style.fontSize ?? SdSpacingConstant.sp14).roundToDouble();

  double get _minFontSize =>
      (minFontSize ?? SdSpacingConstant.sp8).roundToDouble();

  /// Widest of [texts] laid out on one line at [fontSize].
  double _widestAt(BuildContext context, double fontSize, List<String> texts) {
    double widest = 0;

    for (final String text in texts) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: text, style: style.copyWith(fontSize: fontSize)),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();

      widest = math.max(widest, painter.width);
      painter.dispose();
    }

    return widest;
  }

  /// The largest size on the [sharedStep] ladder at which every label in the
  /// set still fits [maxWidth].
  double _sharedFontSize(BuildContext context, double maxWidth) {
    final List<String> texts = <String>[
      _processedLabel,
      for (final String peer in peers)
        stripNewlines ? peer.replaceAll('\n', ' ') : peer,
    ];
    final double max = _maxFontSize;
    final double widest = _widestAt(context, max, texts);

    if (widest <= maxWidth || widest == 0 || !maxWidth.isFinite) return max;

    // Glyph advances scale with the font size, so one measurement gives the
    // answer directly — but `letterSpacing` does not scale, so the estimate
    // can still come out a hair wide. Walk it down the ladder until it fits;
    // with no letter spacing that loop never runs.
    double size =
        (max * maxWidth / widest / sharedStep).floorToDouble() * sharedStep;

    while (size > _minFontSize && _widestAt(context, size, texts) > maxWidth) {
      size -= sharedStep;
    }

    return math.max(size, _minFontSize);
  }

  @override
  Widget build(BuildContext context) {
    if (peers.isEmpty) {
      const double step = 0.1;

      return AutoSizeText(
        _processedLabel,
        style: style.copyWith(fontSize: _maxFontSize),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        minFontSize: _minFontSize,
        stepGranularity: step,
      );
    }

    assert(maxLines == 1, 'peers sizes one line of text; maxLines must be 1');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Text(
        _processedLabel,
        style: style.copyWith(
          fontSize: _sharedFontSize(context, constraints.maxWidth),
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
