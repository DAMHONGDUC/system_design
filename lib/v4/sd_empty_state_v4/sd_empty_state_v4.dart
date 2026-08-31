import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_icon_v4/sd_icon_v4.dart';

final class SdEmptyStateV4 extends StatelessWidget {
  const SdEmptyStateV4({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.all(SdSpacingConstant.r24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(SdSpacingConstant.r16),
              child: SdIconV4(icon, color: colorScheme.primary),
            ),
          ),
          SizedBox(height: SdSpacingConstant.h16),
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: SdSpacingConstant.h8),
          Text(
            description,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (action case final Widget action) ...<Widget>[
            SizedBox(height: SdSpacingConstant.h20),
            action,
          ],
        ],
      ),
    );
  }
}
