import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// The one card surface: the card colour and the card radius, and nothing
/// else.
///
/// **No padding and no margin, deliberately.** Material's `Card` carries an
/// invisible `EdgeInsets.all(4)` margin, which is how a list whose separator
/// said 8 came out 16 and sat 8 narrower than the list beside it. Spacing
/// belongs to whoever places the card; the inset inside it belongs to
/// whatever it holds.
///
/// Pass [onTap] to make the whole card pressable — the ink is clipped to the
/// radius, which is the reason it lives here rather than at each call site.
class SdCardV2 extends StatelessWidget {
  const SdCardV2({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  /// The corner every card in the app wears.
  static double get radius => SdSpacingConstant.r16;

  @override
  Widget build(BuildContext context) {
    final BorderRadius shape = BorderRadius.circular(radius);

    return Material(
      color: context.colorScheme.surface,
      borderRadius: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? child
          : InkWell(onTap: onTap, borderRadius: shape, child: child),
    );
  }
}
