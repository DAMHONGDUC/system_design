import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';

part 'sd_action_view_v2_pinned.dart';
part 'sd_action_view_v2_scrolling.dart';

/// Where [SdActionViewV2.actions] sit once the content is taller than the
/// viewport — a prop, like every other look in this package.
///
/// - [scrolling] — content and actions share one scroll view, with the free
///   space between them. Right when the actions are the end of the content:
///   a sign-in screen, an account screen, a premium screen.
/// - [pinned] — only the content scrolls and the actions hold the bottom
///   edge however long it gets. Right when the content is a list that grows
///   without bound, where a scrolling action is one the user has to go
///   looking for.
enum SdActionsPlacementV2 { scrolling, pinned }

/// Body layout for any screen that is "content, then an action at the
/// bottom": the sign-in screen, the account screen, the premium screen.
///
/// [content] sits at the top, [actions] hug the bottom edge, and the space
/// between them is whatever is left over. Pass it straight as
/// `SdScaffoldV2.body` and leave the scroll view to this widget.
///
/// [placement] decides what happens once the two together outgrow one
/// viewport — which long locales and large accessibility text sizes make a
/// matter of when, not if. The default scrolls them together; a screen whose
/// content is an unbounded list wants [SdActionsPlacementV2.pinned] instead.
///
/// Three things it owns, so no screen has to remember them (CLAUDE.md
/// § Code style):
/// - the vertical insets, straight from [SdContentPaddingV2] — so [content]
///   must not open with a gap of its own, or the two stack up;
/// - the minimum height under [SdActionsPlacementV2.scrolling], which is what
///   gives `spaceBetween` free space to push the actions down — without it
///   the column shrink-wraps and the buttons drift into the middle under
///   short content;
/// - the gap above a pinned footer, [SdContentPaddingV2.pinnedActionsGap].
///
/// [actions] is a stretched column, so buttons come out full width and the
/// same width as each other whatever their labels say.
class SdActionViewV2 extends StatelessWidget {
  const SdActionViewV2({
    required this.content,
    required this.actions,
    this.placement = SdActionsPlacementV2.scrolling,
    this.contentPadding,
    this.actionsPadding,
    this.actionSpacing,
    super.key,
  });

  final Widget content;

  /// Bottom-pinned, in order. Usually one or two [SdButtonV2]s.
  final List<Widget> actions;

  /// Whether [actions] travel with the content or hold the bottom edge.
  final SdActionsPlacementV2 placement;

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
    final Widget actionColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: actionSpacing ?? SdSpacingConstant.h8,
      children: actions,
    );

    return switch (placement) {
      SdActionsPlacementV2.scrolling => _Scrolling(
        contentInsets: contentInsets,
        actionInsets: actionInsets,
        actions: actionColumn,
        content: content,
      ),
      SdActionsPlacementV2.pinned => _Pinned(
        contentInsets: contentInsets,
        actionInsets: actionInsets,
        actions: actionColumn,
        content: content,
      ),
    };
  }
}
