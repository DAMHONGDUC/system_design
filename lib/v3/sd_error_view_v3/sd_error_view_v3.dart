import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// How loud the view is: what the glyph is coloured with.
///
/// **An enum rather than a `Color` parameter.** A colour at the call site is
/// one a screen can pick from anywhere, including from outside the theme; a
/// tone is a choice between the two the palette has a name for.
enum SdErrorToneV3 {
  /// Something is broken. [SdThemeV3.danger].
  error,

  /// Something the reader should know before they carry on, but nothing is
  /// broken — a planned outage, a notice the product wants read.
  /// [SdThemeV3.warning].
  warning,
}

/// A failure that took the whole screen with it: a glyph, what happened, and
/// — outside production — what the SDK actually said.
///
/// **This is not [SdEmptyStateV3], and the difference is where it sits.** An
/// empty state lives *inside* a screen that is working: a tab with no rows
/// yet, a chart with no data, a load that failed under an app bar the seller
/// can still leave by. This one *is* the screen — it paints its own surface
/// and its own safe area, because whatever it replaced is gone and there is no
/// scaffold left to sit in. That is also why the glyph carries a status
/// colour rather than `textTertiary`: an empty state says "normal, nothing
/// here yet", and this one says something happened. Which of the two it says
/// is [tone].
///
/// It owns no strings and no idea of what failed. The host passes [title] and
/// [message] already localized, and passes [detail] only where it should be
/// read — a debug build, a dev flavour, a support screen. Pass null and the
/// row is not drawn.
///
/// The column centres while it fits and scrolls once it does not, which long
/// locales and large accessibility text sizes make a matter of when rather
/// than if — and an error screen that overflows is the one screen with no
/// other way to tell the user anything.
class SdErrorViewV3 extends StatelessWidget {
  const SdErrorViewV3({
    required this.icon,
    required this.title,
    required this.message,
    this.tone = SdErrorToneV3.error,
    this.detail,
    this.action,
    super.key,
  });

  /// The glyph over the title. Required, like [SdEmptyStateV3]'s: the host
  /// owns its icon set, and this package does not guess which error glyph a
  /// product draws.
  final IconData icon;

  /// How loud it is. Defaults to [SdErrorToneV3.error], which is what this
  /// view drew before there was a choice.
  final SdErrorToneV3 tone;

  /// One line saying what happened, in the user's language.
  final String title;

  /// What they can do about it, in the user's language.
  final String message;

  /// A third line, smaller and quieter than [message]. Null hides the row.
  ///
  /// Usually the raw failure, passed only where it should be read — a debug
  /// build, a dev flavour, a support screen. A host with a second sentence of
  /// its own puts it here too; the slot is a line, not a category.
  final String? detail;

  /// The recovery, if there is one. Pass an `SdButtonV3`; this widget does not
  /// grow its own button style.
  final Widget? action;

  /// Big enough to be the thing the eye lands on: nothing else is on screen.
  static double get iconSize => SdSpacingConstant.r48;

  /// [detail] is built from an exception, so its length is the SDK's choice,
  /// not the host's. Six lines is what a tester can still photograph next to
  /// the title and the message; the rest belongs in the log.
  static const int detailMaxLines = 6;

  @override
  Widget build(BuildContext context) {
    final String? failure = detail;
    final Widget? recovery = action;

    return Material(
      // The page colour, not `surface` — in v3 `surface` is the card, one step
      // above the page, and a full-screen view painted in it reads as a card
      // with nothing behind it.
      color: context.sdTheme3.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: SdContentPaddingV3.horizontal,
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
                        SdIconV3(
                          icon,
                          size: iconSize,
                          color: switch (tone) {
                            SdErrorToneV3.error => context.sdTheme3.danger,
                            SdErrorToneV3.warning => context.sdTheme3.warning,
                          },
                        ),
                        SizedBox(height: SdSpacingConstant.h16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: context.textTheme3.titleLarge!.semiBold3
                              .copyWith(color: context.sdTheme3.textPrimary),
                        ),
                        SizedBox(height: SdSpacingConstant.h8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: context.textTheme3.bodyMedium!.muted3(context),
                        ),
                        if (failure != null) ...<Widget>[
                          SizedBox(height: SdSpacingConstant.h24),
                          Text(
                            failure,
                            textAlign: TextAlign.center,
                            maxLines: detailMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme3.bodySmall!.muted3(context),
                          ),
                        ],
                        if (recovery != null) ...<Widget>[
                          SizedBox(height: SdSpacingConstant.h24),
                          recovery,
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
