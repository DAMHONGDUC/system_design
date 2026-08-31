import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// How much room an [SdEmptyStateV2] takes — a prop, like every other look in
/// this system.
///
/// - [full] — a screen or a tab with nothing in it. The glyph is large enough
///   to be the thing the eye lands on, because nothing else on the screen is.
/// - [compact] — a slot inside something that is not empty: a chart's plot
///   area, one section of a card. The full size there would push the card to
///   twice the height its content will need once it arrives.
enum SdEmptyStateSizeV2 { full, compact }

/// Calm, shared empty/error state: a muted icon over a short message.
/// No illustration, no bright colours — photophobia-first (hard rule 3).
///
/// **An empty state is never text alone** (owner's rule). A line of grey
/// prose where content should be reads as a caption on something missing, or
/// as a failure; the glyph is what says "this is a state, and it is a normal
/// one". Use [SdEmptyStateSizeV2.compact] where the full block would not fit
/// rather than dropping back to a bare `Text`.
class SdEmptyStateV2 extends StatelessWidget {
  const SdEmptyStateV2({
    required this.icon,
    required this.message,
    this.size = SdEmptyStateSizeV2.full,
    super.key,
  });

  final IconData icon;
  final String message;
  final SdEmptyStateSizeV2 size;

  /// Half its opacity: the glyph frames the message, it does not compete with
  /// it.
  static const double iconOpacity = 0.5;

  double get _iconSize => switch (size) {
    SdEmptyStateSizeV2.full => SdSpacingConstant.r64,
    SdEmptyStateSizeV2.compact => SdSpacingConstant.r32,
  };

  double get _verticalPadding => switch (size) {
    SdEmptyStateSizeV2.full => SdSpacingConstant.h24,
    SdEmptyStateSizeV2.compact => SdSpacingConstant.h12,
  };

  double get _gap => switch (size) {
    SdEmptyStateSizeV2.full => SdSpacingConstant.h12,
    SdEmptyStateSizeV2.compact => SdSpacingConstant.h8,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          // The compact one sits inside something that already holds a gutter.
          horizontal: size == SdEmptyStateSizeV2.full
              ? SdContentPaddingV2.horizontal
              : 0,
          vertical: _verticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SdIconV2(
              icon: icon,
              size: _iconSize,
              color: scheme.onSurfaceVariant.withValues(alpha: iconOpacity),
            ),
            SizedBox(height: _gap),
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
