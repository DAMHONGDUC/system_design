import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// A failure that took the whole screen with it: an error glyph, what
/// happened, and — outside production — what the SDK actually said.
///
/// **This is not [SdEmptyStateV2], and the difference is where it sits.** An
/// empty state lives *inside* a screen that is working: a tab with no rows
/// yet, a chart with no data. This one *is* the screen — it paints its own
/// surface and its own safe area, because whatever it replaced is gone. That
/// is also why the glyph is `colorScheme.error` rather than muted: an empty
/// state says "normal, nothing here yet", and this says "broken".
///
/// It owns no strings and no idea of what failed. The host passes [title] and
/// [message] already localized, and passes [detail] only where it should be
/// read — a build's flavour, a debug switch, a support screen. Pass null and
/// the row is not drawn.
///
/// The column centres while it fits and scrolls once it does not, which long
/// locales and large accessibility text sizes make a matter of when rather
/// than if — and an error screen that overflows is the one screen with no
/// other way to tell the user anything.
class SdErrorViewV2 extends StatelessWidget {
  const SdErrorViewV2({
    required this.icon,
    required this.title,
    required this.message,
    this.detail,
    super.key,
  });

  /// The glyph over the title. Required, like [SdEmptyStateV2]'s: the host
  /// owns its icon set, and this package does not guess which error glyph a
  /// product draws.
  final IconData icon;

  /// One line saying what happened, in the user's language.
  final String title;

  /// What they can do about it, in the user's language.
  final String message;

  /// The raw failure, for whoever can act on it. Null hides the row.
  final String? detail;

  /// Big enough to be the thing the eye lands on: nothing else is on screen.
  static double get iconSize => SdSpacingConstant.r48;

  /// [detail] is built from an exception, so its length is the SDK's choice,
  /// not the host's. Six lines is what a tester can still photograph next to
  /// the title and the message; the rest belongs in the log.
  static const int detailMaxLines = 6;

  @override
  Widget build(BuildContext context) {
    final String? failure = detail;

    return Material(
      color: context.colorScheme.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: SdContentPaddingV2.horizontal,
                  vertical: SdSpacingConstant.h24,
                ),
                child: ConstrainedBox(
                  // Minus the padding above, or the centre sits low by it.
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - SdSpacingConstant.h24 * 2,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SdIconV2(
                          icon: icon,
                          size: iconSize,
                          color: context.colorScheme.error,
                        ),
                        SizedBox(height: SdSpacingConstant.h16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleLarge!.semiBold,
                        ),
                        SizedBox(height: SdSpacingConstant.h8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium!.muted(context),
                        ),
                        if (failure != null) ...<Widget>[
                          SizedBox(height: SdSpacingConstant.h24),
                          Text(
                            failure,
                            textAlign: TextAlign.center,
                            maxLines: detailMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall!.muted(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
