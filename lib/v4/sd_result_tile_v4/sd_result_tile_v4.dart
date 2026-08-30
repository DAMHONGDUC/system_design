import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

class SdResultTileV4 extends StatelessWidget {
  const SdResultTileV4({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SdSpacingConstant.h6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          SizedBox(width: SdSpacingConstant.w12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
