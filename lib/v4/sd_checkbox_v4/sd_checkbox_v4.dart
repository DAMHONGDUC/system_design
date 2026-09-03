import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

final class SdCheckboxV4 extends StatelessWidget {
  const SdCheckboxV4({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: SdSpacingConstant.h48),
    child: CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      horizontalTitleGap: SdSpacingConstant.w4,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      value: value,
      onChanged: (bool? selected) => onChanged(selected ?? false),
    ),
  );
}
