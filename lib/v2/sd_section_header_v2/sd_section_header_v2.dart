import 'package:flutter/material.dart';

import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// Label above a group of rows. Quiet by design; its spacing comes from
/// [SdContentPaddingV2.sectionHeader], so callers just drop it between
/// groups — and pass `first: true` for the one at the top of a screen.
class SdSectionHeaderV2 extends StatelessWidget {
  const SdSectionHeaderV2(this.title, {this.first = false, super.key});

  final String title;

  /// True for the first heading on a screen: the screen's own top gap has
  /// already placed it, so it drops the separator gap it would otherwise
  /// keep from the group above (see [SdContentPaddingV2.sectionHeader]).
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SdContentPaddingV2.sectionHeader(first: first),
      child: Text(
        title,
        style: context.textTheme.labelLarge!.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
