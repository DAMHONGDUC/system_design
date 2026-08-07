import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// The app's hairline separator — one thickness, one colour, everywhere.
///
/// Deliberately not Material's [Divider]: that one reserves a whole `height`
/// (16 by default) around a 0-thickness line, so a "1px rule" silently costs
/// 16 of vertical space and two rows drift apart for reasons nothing at the
/// call site explains. This draws the line and occupies exactly it — the gap
/// around a divider belongs to whatever is placing it.
///
/// [SdSpacingConstant.h1] thick, in `sdTheme.surfaceElevated` — the same step
/// up from a card that everything else sitting *on* a card takes, so a
/// separator inside a card reads as part of the same language rather than as
/// a fifth grey.
class SdDividerV2 extends StatelessWidget {
  const SdDividerV2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SdSpacingConstant.h1,
      child: ColoredBox(
        color: context.sdTheme.surfaceElevated,
        // Stretches to the parent's width; a bare ColoredBox would size to nothing.
        child: const SizedBox(width: double.infinity),
      ),
    );
  }
}
