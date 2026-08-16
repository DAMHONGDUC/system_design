import 'package:flutter/material.dart';

import '../sd_context_v3/sd_context_v3.dart';

/// The one divider in v3 — feature code never uses a raw [Divider].
///
/// **Material's [Divider] reserves a whole `height` around a rule that is
/// only [thickness] tall**, and that height defaults to 16. A call site
/// asking for "a 1px line" silently costs 16 of vertical space, so two rows
/// drift apart for a reason nothing at the call site explains and the gap
/// cannot be reconciled with the spacing ladder.
///
/// This one occupies exactly the line it draws, plus whatever [gap] is asked
/// for explicitly on each side. It also resolves its own colour, so seven
/// call sites stop repeating `color: context.sdTheme3.divider`.
///
/// **Draw it between items only.** A rule on a container's own edge reads as
/// a border the container does not have.
class SdDividerV3 extends StatelessWidget {
  const SdDividerV3({this.gap = 0, super.key});

  /// How tall the rule itself is. The widget's own intrinsic size — what it
  /// *is*, not configuration about it.
  static const double thickness = 1;

  /// Breathing room above and below, from `SdSpacingConstant.h*`. Zero means
  /// the divider takes exactly [thickness], which is the default because a
  /// gap nobody asked for is the bug this widget exists to stop.
  final double gap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: gap),
    child: SizedBox(
      height: thickness,
      width: double.infinity,
      child: ColoredBox(color: context.sdTheme3.divider),
    ),
  );
}
