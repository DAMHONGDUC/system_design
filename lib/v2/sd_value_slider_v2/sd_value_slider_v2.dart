import 'package:flutter/material.dart';

import '../sd_context_v2/sd_context_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// A number the user drags: the current value, big, over the slider that
/// sets it. Used by the attack detail's intensity dialog and onboarding's
/// pressure threshold page — the same control, so it lives here rather than
/// being written twice.
///
/// [accent] colours the readout and the active track together. Callers pass
/// the accent the call site passes so the number carries the app's one severity
/// ramp (green → yellow → orange → red) instead of each screen inventing a
/// tint. Colour is never the only signal: [label] is the value in words the
/// caller already localized ("7", "5 hPa").
///
/// [readout] replaces that drawn number when the value can also be *typed* —
/// a wide range is hard to hit by dragging, and a field is the only way in
/// for someone who cannot drag at all. The caller owns the field, because a
/// text input needs a controller, a keyboard type and an error message, none
/// of which a slider should know about.
class SdValueSliderV2 extends StatelessWidget {
  const SdValueSliderV2({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.accent,
    this.readout,
    super.key,
  });

  /// The localized readout above the slider. Ignored when [readout] is
  /// passed, and still required: a slider whose number can be typed is the
  /// exception, and a caller that drops the label has nothing to fall back on.
  final String label;

  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  /// Readout + active track colour. Defaults to the theme's primary.
  final Color? accent;

  /// Stands where the drawn number would — a field, usually. See the class
  /// doc.
  final Widget? readout;

  @override
  Widget build(BuildContext context) {
    final Color color = accent ?? context.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        readout ??
            Text(
              label,
              style: context.textTheme.displaySmall!.semiBold.copyWith(
                color: color,
              ),
            ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
