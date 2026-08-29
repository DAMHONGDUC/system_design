import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';

/// Shows [SdDialogV2] (or any dialog content) with a calm fade + gentle
/// scale on open, reversed on close (hard rule 3: nothing flashy).
/// Always use this instead of raw [showDialog].
Future<T?> showSdDialogV2<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.sdTheme.barrier,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) => builder(dialogContext),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Base dialog: consistent surface, radius, paddings, and action row.
class SdDialogV2 extends StatelessWidget {
  const SdDialogV2({
    required this.title,
    this.content,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.sdTheme.surfaceModal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SdSpacingConstant.r20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: SdSpacingConstant.w32),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          SdContentPaddingV2.horizontal,
          SdSpacingConstant.h22,
          SdContentPaddingV2.horizontal,
          SdSpacingConstant.h16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: context.textTheme.titleLarge!),
            if (content != null) ...[
              SizedBox(height: SdSpacingConstant.h16),
              content!,
            ],
            if (actions.isNotEmpty) ...[
              SizedBox(height: SdSpacingConstant.h20),
              // Falls back to stacking the actions when a narrow dialog
              // (insetPadding leaves little room) can't fit them side by
              // side — a plain Row overflows instead of ever giving up the
              // row layout.
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: SdSpacingConstant.w8,
                overflowSpacing: SdSpacingConstant.h8,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A tappable row inside an [SdDialogV2] (pickers, option lists).
class SdDialogOptionV2 extends StatelessWidget {
  const SdDialogOptionV2({
    required this.label,
    required this.onTap,
    this.icon,
    this.selected,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  /// Non-null shows a radio indicator on the trailing edge.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(SdSpacingConstant.r12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SdSpacingConstant.w8,
          vertical: SdSpacingConstant.h12,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              SdIconV2(
                icon: icon!,
                size: SdSpacingConstant.r20,
                color: scheme.primary,
              ),
              SizedBox(width: SdSpacingConstant.w12),
            ],
            Expanded(child: Text(label, style: context.textTheme.bodyLarge!)),
            if (selected != null)
              SdIconV2(
                icon: selected!
                    ? Symbols.radio_button_checked_rounded
                    : Symbols.radio_button_unchecked_rounded,
                size: SdSpacingConstant.r20,
                color: selected! ? scheme.primary : scheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
