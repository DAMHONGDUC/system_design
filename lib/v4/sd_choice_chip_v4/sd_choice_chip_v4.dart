import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

final class SdChoiceChipV4 extends StatelessWidget {
  const SdChoiceChipV4({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: label,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: SdSpacingConstant.h48),
      child: FilterChip(
        label: Text(label, style: Theme.of(context).textTheme.labelLarge),
        selected: selected,
        onSelected: onSelected,
      ),
    ),
  );
}
