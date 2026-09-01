import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The heading over a group of rows or cards — "Needs Attention", "Recent
/// Activity", "Pricing".
///
/// [leading] is the mark in front of the title — a colour dot for the record
/// the group is about. A widget rather than a colour, so the package never
/// learns what the mark means.
///
/// [action] is the trailing affordance a section header almost always grows:
/// "See all" on Home's blocks, "Edit" on a detail screen's section. It takes a
/// widget rather than a label plus callback so the call site can pass an
/// `SdButtonV3(variant: text)` and get the app's real button, instead of this
/// widget growing its own third button style.
class SdSectionHeaderV3 extends StatelessWidget {
  const SdSectionHeaderV3({
    required this.title,
    this.subtitle,
    this.leading,
    this.action,
    this.first = false,
    this.gutter = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? action;

  /// The gap between [leading] and the title. Tight enough that the mark reads
  /// as part of the heading rather than as a control beside it.
  static double get leadingGap => SdSpacingConstant.w8;

  /// Drops the gap above. Pass `true` for the first heading on a screen — the
  /// screen's own top padding has already placed it.
  final bool first;

  /// Whether the heading carries the screen's side inset.
  ///
  /// **A flag, not a padding the caller passes.** A heading inside a card or
  /// a padded block wants the gutter dropped and the vertical rhythm kept,
  /// which is one answer rather than an open question — and a widget owns
  /// only its own intrinsic size (`WIDGET_RULES.md` §6), so what it is padded
  /// by comes from `SdContentPaddingV3` and never from a call site.
  final bool gutter;

  @override
  Widget build(BuildContext context) => Padding(
    padding: SdContentPaddingV3.sectionHeader(first: first, gutter: gutter),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (leading != null) ...<Widget>[leading!, SizedBox(width: leadingGap)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: context.textTheme3.titleMedium!.semiBold3.copyWith(
                  color: context.sdTheme3.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: context.textTheme3.bodySmall!.muted3(context),
                ),
            ],
          ),
        ),
        ?action,
      ],
    ),
  );
}
