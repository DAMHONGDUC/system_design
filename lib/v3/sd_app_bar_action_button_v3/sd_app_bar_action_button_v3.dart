import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';

/// One icon action in a header's trailing slot.
///
/// A value type rather than a widget, for the same reason
/// `SdNavDestinationV3` is one: the header reserves an exact width for the
/// trailing slot and subtracts it from the search field beside it. An action
/// that brought its own widget would size itself, and the field would either
/// overlap it or stop short of it by a number nobody could predict.
@immutable
class SdAppBarActionV3 {
  const SdAppBarActionV3({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;

  /// Tooltip and semantics label. A parameter because this package holds no
  /// strings.
  final String tooltip;

  final VoidCallback onPressed;

  /// The width one action occupies, and its tap target. Square, so the row of
  /// them is `count × slot` and the header can do that arithmetic without
  /// laying anything out.
  static double get slot => SdSpacingConstant.w44;
}

/// The one icon-only action in a v3 app bar — a screen never builds its own
/// [IconButton] there.
///
/// It exists because the same control was drawn six ways across one app:
/// three at Material's ambient icon size, two at [SdIconV3.defaultSize] and
/// two at `r24`. A bar a user moves between all day is the last place a
/// control may change size.
///
/// **The glyph is [glyphSize], larger than [SdIconV3.defaultSize]** — an
/// action at the top of every screen that has to be looked for is one people
/// stop reaching for. The slot around it stays [SdAppBarActionV3.slot], so a
/// row of them is still `count × slot` and the search header can lay them out
/// without measuring.
class SdAppBarActionButtonV3 extends StatelessWidget {
  const SdAppBarActionButtonV3({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.tint,
    this.dotColor,
    super.key,
  });

  final IconData icon;

  /// Tooltip and semantics label. A parameter because this package holds no
  /// strings.
  final String tooltip;

  /// Null disables the action rather than removing it — a delete refused
  /// while a save is in flight would otherwise move every action beside it.
  final VoidCallback? onPressed;

  /// Overrides [SdThemeV3.textPrimary] — for an action that carries a colour
  /// of its own, a destructive one above all.
  final Color? tint;

  /// Draws a mark on the glyph's corner when non-null: something is waiting.
  ///
  /// **Here rather than a `Stack` at the call site**, because the dot has to
  /// sit on the corner of a glyph whose size only this widget knows.
  final Color? dotColor;

  /// The glyph an app bar action draws. Intrinsic to this control — what it
  /// *is*, not configuration about it.
  static double get glyphSize => SdSpacingConstant.r24;

  /// The unread mark's diameter, and how far it is pulled past the glyph's
  /// corner. Both intrinsic, for the same reason.
  static double get dotSize => SdSpacingConstant.w8;
  static double get dotInset => -SdSpacingConstant.w2;

  @override
  Widget build(BuildContext context) {
    final Color? mark = dotColor;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      // shrinkWrap or the button silently reserves a 48pt tap target whatever
      // `constraints` says — taller than the bar row on any device shorter
      // than the design canvas, which overflows the row.
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      constraints: BoxConstraints.tightFor(
        width: SdAppBarActionV3.slot,
        height: SdAppBarActionV3.slot,
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SdIconV3(
            icon,
            size: glyphSize,
            color: tint ?? context.sdTheme3.textPrimary,
            semanticLabel: tooltip,
          ),
          if (mark != null)
            Positioned(
              top: dotInset,
              right: dotInset,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(color: mark, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}
