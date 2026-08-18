import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_card_v2/sd_card_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_badge_v2/sd_icon_badge_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// A tappable feature banner: a tinted leading icon badge, a title and one
/// supporting line, and a trailing chevron. Used to surface something that
/// lives elsewhere (reminders, insights, export).
class SdBannerV2 extends StatelessWidget {
  const SdBannerV2({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.subtitleChild,
    this.borderColor,
    super.key,
  });

  final IconData icon;

  /// Accent tint for the leading icon badge (its background is this at low
  /// alpha, the glyph is this at full strength).
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Optional rich replacement for the plain [subtitle] Text — e.g. one that
  /// emphasises a live countdown inside the line. When null the plain
  /// [subtitle] is shown.
  final Widget? subtitleChild;

  /// Outlines the banner in this colour — for the one banner in a stack that
  /// has to be seen first. Straight through to [SdCardV2.borderColor].
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SdCardV2(
      onTap: onTap,
      borderColor: borderColor,
      child: Padding(
        padding: EdgeInsets.all(SdSpacingConstant.w16),
        child: Row(
          children: [
            SdIconBadgeV2(icon: icon, color: color),
            SizedBox(width: SdSpacingConstant.w16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleMedium!),
                  SizedBox(height: SdSpacingConstant.h2),
                  subtitleChild ??
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall!.muted(context),
                      ),
                ],
              ),
            ),
            SizedBox(width: SdSpacingConstant.w8),
            SdIconV2(
              icon: Icons.chevron_right,
              size: SdSpacingConstant.r20,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
