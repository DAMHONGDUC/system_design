import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The caption above a form row, and the one place the required marker is
/// drawn.
///
/// Its own widget because three different rows wear it — a text field, a money
/// field, a row whose value comes from a sheet — and a marker each of them
/// appended for itself is a marker in three weights.
///
/// **The asterisk is excluded from semantics.** A screen reader saying "star"
/// after every required label is noise; the field beside it already announces
/// what it is.
class SdFieldLabelV3 extends StatelessWidget {
  const SdFieldLabelV3({
    required this.label,
    this.isRequired = false,
    this.enabled = true,
    super.key,
  });

  final String label;

  /// Draws the marker. What *makes* a field required is the form's own
  /// validation; this only says so.
  final bool isRequired;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.textTheme3.labelMedium!.semiBold3.copyWith(
      color: enabled
          ? context.sdTheme3.textSecondary
          : context.sdTheme3.textTertiary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(child: Text(label, style: style)),
        if (isRequired) ...<Widget>[
          SizedBox(width: SdSpacingConstant.w4),
          ExcludeSemantics(
            child: Text(
              '*',
              style: style.copyWith(color: context.sdTheme3.danger),
            ),
          ),
        ],
      ],
    );
  }
}
