import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_bottom_sheet_v2/sd_bottom_sheet_v2.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_filter_pill_v2/sd_filter_pill_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';

/// Opens a single-choice filter sheet: a plain radio list of [options],
/// [selected] pre-checked. Returns the picked value, or null if dismissed
/// without a pick. Generic over the filtered dimension — [labelBuilder]
/// supplies the localized label per value, so this has no opinion about
/// what's being filtered.
///
/// Shared by every screen that filters a list along one enum-like axis:
/// History's period filter, and the medications tab's three independent
/// filters (date added, reminder, usage) — each opens its own instance of
/// this sheet rather than one combined multi-axis picker, so every filter
/// stays a simple, single-tap choice.
Future<T?> showSdFilterSheetV2<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T value) labelBuilder,
}) {
  return showSdBottomSheetV2<T>(
    context,
    builder: (_) => _FilterSheet<T>(
      title: title,
      options: options,
      selected: selected,
      labelBuilder: labelBuilder,
    ),
  );
}

/// The filter pill (icon + current value + expand chevron); tapping opens
/// [showSdFilterSheetV2]. Meant to sit at the top of the filtered content,
/// below the app bar — same slot History used before this was generalized.
class SdFilterChipV2<T> extends StatelessWidget {
  const SdFilterChipV2({
    required this.label,
    required this.selected,
    required this.options,
    required this.optionLabelBuilder,
    required this.onSelected,
    required this.sheetTitle,
    this.active = false,
    this.count,
    this.countLabelBuilder,
    super.key,
  }) : assert(
         count == null || countLabelBuilder != null,
         'countLabelBuilder is required whenever count is passed',
       );

  /// Text shown on the closed chip. Kept separate from [optionLabelBuilder]
  /// because a screen with one filter (History) can just show the picked
  /// value, but a screen with several filters side by side (the medications
  /// tab) needs each chip to also carry its own axis name — otherwise
  /// several chips all resting on their default value would all read "All"
  /// with nothing to tell them apart. The caller decides; this widget has
  /// no way to know which value in [options] means "no filter".
  final String label;

  final T selected;
  final List<T> options;

  /// Labels one option inside the open sheet's radio list. Deliberately
  /// separate from [label] — the sheet lists every option by its own value,
  /// never by axis name (that would repeat the sheet's [sheetTitle] on
  /// every row).
  final String Function(T value) optionLabelBuilder;
  final ValueChanged<T> onSelected;

  /// Title shown above the option list in the sheet, and reused as the
  /// chip's own accessibility label context.
  final String sheetTitle;

  /// True while this axis is narrowing the list — anything but its "all".
  /// Drawn by [SdFilterPillV2]; the caller decides, because only it knows
  /// which value in [options] means "no filter".
  final bool active;

  /// How many items the current selection matches — appended to the label
  /// via [countLabelBuilder] when non-null (e.g. "All (10)").
  final int? count;

  /// Combines the selected option's label with [count] into display text.
  /// Callers that pass [count] must supply this through their own ARB
  /// entry — word order around a count varies by locale, so this widget
  /// never hardcodes the composed string itself (hard rule: every
  /// user-facing string goes through intl). Ignored when [count] is null.
  final String Function(String label, int count)? countLabelBuilder;

  Future<void> _open(BuildContext context) async {
    final picked = await showSdFilterSheetV2<T>(
      context,
      title: sheetTitle,
      options: options,
      selected: selected,
      labelBuilder: optionLabelBuilder,
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return SdFilterPillV2(
      label: count == null ? label : countLabelBuilder!(label, count!),
      active: active,
      onTap: () => _open(context),
    );
  }
}

class _FilterSheet<T> extends StatelessWidget {
  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelBuilder,
  });

  final String title;
  final List<T> options;
  final T selected;
  final String Function(T value) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              SdContentPaddingV2.horizontal,
              SdSpacingConstant.h4,
              SdContentPaddingV2.horizontal,
              SdSpacingConstant.h12,
            ),
            child: Text(title, style: context.textTheme.titleMedium!),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    leading: SdIconV2(
                      icon: option == selected
                          ? Symbols.radio_button_checked_rounded
                          : Symbols.radio_button_unchecked_rounded,
                      color: option == selected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      size: SdSpacingConstant.r22,
                    ),
                    title: Text(
                      labelBuilder(option),
                      style: context.textTheme.bodyLarge!,
                    ),
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
          SizedBox(height: SdSpacingConstant.h8),
        ],
      ),
    );
  }
}
