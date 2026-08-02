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
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Marker beside the title — a badge saying this one is not included, say.
  /// It sits on the title's line, not the row's centre, so a two-line body
  /// cannot drag it out of alignment with the heading it qualifies.
  final Widget? trailing;

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(title, style: context.textTheme.titleMedium!),
                    ),
                    if (trailing != null) ...<Widget>[
                      SizedBox(width: SdSpacingV2.w8),
                      trailing!,
                    ],
                  ],
                ),
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
