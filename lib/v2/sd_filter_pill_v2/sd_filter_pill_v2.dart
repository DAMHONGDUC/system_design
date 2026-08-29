import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';

/// The pill that opens a filter: a leading filter glyph, the value currently
/// filtered to, a chevron saying there is more behind it.
///
/// Look only — what the tap opens belongs to the caller. `SdFilterChipV2` puts
/// a single-choice sheet behind it (History's period, the medications tab's
/// three axes); the export screen puts its own date-range sheet there. The
/// pill itself is shared so those never drift into two different pills.
class SdFilterPillV2 extends StatelessWidget {
  const SdFilterPillV2({required this.label, required this.onTap, super.key});

  /// The pill's own height — what History measures its scroll hand-off against
  /// (`_FilterRow.scrolledPastExtent`), since the pill leads the list there.
  static double get pillHeight => SdSpacingConstant.h34;

  /// Text on the closed pill — the finished, localized value.
  final String label;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
      child: InkWell(
        borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SdSpacingConstant.w14,
            vertical: SdSpacingConstant.h8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SdIconV2(
                icon: Symbols.filter_list_rounded,
                size: SdSpacingConstant.r16,
                color: scheme.primary,
              ),
              SizedBox(width: SdSpacingConstant.w6),
              Text(label, style: context.textTheme.labelLarge!),
              SizedBox(width: SdSpacingConstant.w2),
              SdIconV2(
                icon: Symbols.expand_more_rounded,
                size: SdSpacingConstant.r18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
