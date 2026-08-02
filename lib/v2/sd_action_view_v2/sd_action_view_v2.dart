import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';

/// Body layout for any screen that is "content, then an action at the
/// bottom": the sign-in screen, the account screen, the premium screen.
///
/// [content] sits at the top, [actions] hug the bottom edge, and the space
/// between them is whatever is left over. It scrolls once the two together
/// outgrow one viewport — which long locales and large accessibility text
/// sizes make a matter of when, not if — so pass it straight as
/// `SdScaffoldV2.body` and leave the scroll view to this widget.
///
/// Three things it owns, so no screen has to remember them (CLAUDE.md
/// § Code style):
/// - the vertical insets, straight from [SdContentPaddingV2] — so [content]
///   must not open with a gap of its own, or the two stack up;
/// - the minimum height, which is what gives `spaceBetween` free space to
///   push the actions down — without it the column shrink-wraps and the
///   buttons drift into the middle under short content.
///
/// [actions] is a stretched column, so buttons come out full width and the
/// same width as each other whatever their labels say.
class SdActionViewV2 extends StatelessWidget {
  const SdActionViewV2({
    required this.content,
    required this.actions,
    this.contentPadding,
    this.actionsPadding,
    this.actionSpacing,
    super.key,
  });

  final Widget content;

  /// Bottom-pinned, in order. Usually one or two [SdButtonV2]s.
  final List<Widget> actions;

  /// Horizontal insets for [content]. Defaults to the app's
  /// [SdContentPaddingV2.horizontal] gutter; pass [EdgeInsets.zero] for
  /// full-bleed rows (a `ListTile` brings its own).
  final EdgeInsetsGeometry? contentPadding;

  /// Horizontal insets for [actions]. Defaults to the same gutter — buttons
  /// stay inset even where the content above is full-bleed.
  final EdgeInsetsGeometry? actionsPadding;

  /// Gap between action rows. Defaults to [SdSpacingConstant.h8].
  final double? actionSpacing;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry contentInsets =
        contentPadding ??
        EdgeInsets.symmetric(horizontal: SdContentPaddingV2.horizontal);
    final EdgeInsetsGeometry actionInsets =
        actionsPadding ??
        EdgeInsets.symmetric(horizontal: SdContentPaddingV2.horizontal);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(
                top: SdContentPaddingV2.top(context),
                bottom: SdContentPaddingV2.bottom(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(padding: contentInsets, child: content),
                  Padding(
                    padding: actionInsets,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: actionSpacing ?? SdSpacingConstant.h8,
                      children: actions,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
