import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../../utils/text_ext.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// One "here is what you get" row: icon, title, and an optional supporting
/// line. Shared by the paywall and the login pitch, which sell different
/// things the same way.
class SdBenefitRowV2 extends StatelessWidget {
  const SdBenefitRowV2({
    required this.icon,
    required this.title,
    this.body,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;

  /// The supporting line. Null collapses the row to a single line — for a
  /// list that has to sit beside something else on one screen, where the
  /// titles already say enough.
  final String? body;

  /// Marker beside the title — a badge saying this one is not included, say.
  /// It sits on the title's line, not the row's centre, so a two-line body
  /// cannot drag it out of alignment with the heading it qualifies.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final String? body = this.body;

    return Padding(
      // A one-line row needs less air than a two-line one; the same gap for both makes a compact list look sparse.
      padding: EdgeInsets.only(
        bottom: body == null ? SdSpacingConstant.h12 : SdSpacingConstant.h16,
      ),
      child: Row(
        // One line centres on its icon; two lines hang from the top, so the icon sits beside the title, not the whole block.
        crossAxisAlignment: body == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          SdIconV2(icon: icon, color: context.colorScheme.primary),
          SizedBox(width: SdSpacingConstant.w16),
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
                      SizedBox(width: SdSpacingConstant.w8),
                      trailing!,
                    ],
                  ],
                ),
                if (body.isNotNullAndNotEmpty) ...[
                  SizedBox(height: SdSpacingConstant.h4),
                  Text(
                    body!,
                    style: context.textTheme.bodyMedium!.muted(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
