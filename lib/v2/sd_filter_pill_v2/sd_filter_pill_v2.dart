import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_text_style_v2/sd_text_style_v2.dart';

/// The pill that opens a filter: a leading filter glyph, the value currently
/// filtered to, a chevron saying there is more behind it.
///
/// Look only — what the tap opens belongs to the caller. `SdFilterChipV2` puts
/// a single-choice sheet behind it (History's thirteen axes, the medications
/// tab's three); the export screen puts its own date-range sheet there. The
/// pill itself is shared so those never drift into two different pills.
///
/// **[active] is the whole point of a strip of these.** A row of chips all
/// resting looks exactly like a row where two are narrowing the list, and a
/// filter nobody can see left on is how an empty list reads as an empty
/// history. Active is a tinted fill AND an accent edge AND an accent label:
/// on a dark surface (hard rule 3) a tint alone is not a difference the eye
/// finds while scanning a dozen.
class SdFilterPillV2 extends StatelessWidget {
  const SdFilterPillV2({
    required this.label,
    required this.onTap,
    this.active = false,
    super.key,
  });

  /// How much of the accent an active pill's fill carries.
  static const double _activeFillOpacity = 0.16;

  /// The pill's own height, for a caller that has to reserve the row before
  /// laying one out.
  static double get pillHeight => SdSpacingConstant.h34;

  /// Text on the closed pill — the finished, localized value.
  final String label;

  final VoidCallback onTap;

  /// True while this pill is actually narrowing something — anything other than its "all".
  final bool active;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;

    return Material(
      color: active
          ? scheme.primary.withValues(alpha: _activeFillOpacity)
          : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
      child: InkWell(
        borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
        onTap: onTap,
        child: Container(
          decoration: active
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
                  border: Border.all(color: scheme.primary),
                )
              : null,
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
              Text(
                label,
                style: active
                    ? context.textTheme.labelLarge!.semiBold.copyWith(
                        color: scheme.primary,
                      )
                    : context.textTheme.labelLarge!,
              ),
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
