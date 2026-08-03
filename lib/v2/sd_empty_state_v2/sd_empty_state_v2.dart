import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// Calm, shared empty/error state: a muted icon over a short message.
/// No illustration, no bright colours — photophobia-first (hard rule 3).
class SdEmptyStateV2 extends StatelessWidget {
  const SdEmptyStateV2({required this.icon, required this.message, super.key});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SdContentPaddingV2.horizontal,
          vertical: SdSpacingConstant.h24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SdIconV2(
              icon: icon,
              size: SdSpacingConstant.r64,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: SdSpacingConstant.h12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.muted(context),
            ),
          ],
        ),
      ),
    );
  }
}
