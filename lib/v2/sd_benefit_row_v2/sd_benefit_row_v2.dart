import 'package:flutter/material.dart';

import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_spacing_v2/sd_spacing_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// One "here is what you get" row: icon, title, supporting line. Shared by
/// the paywall and the login pitch, which sell different things the same way.
class SdBenefitRowV2 extends StatelessWidget {
  const SdBenefitRowV2({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SdSpacingV2.h16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SdIconV2(icon: icon, color: context.colorScheme.primary),
          SizedBox(width: SdSpacingV2.w16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: context.textTheme.titleMedium!),
                SizedBox(height: SdSpacingV2.h4),
                Text(body, style: context.textTheme.bodyMedium!.muted(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
