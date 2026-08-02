import 'package:flutter/material.dart';

import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';
import '../sd_spacing_v2/sd_spacing_v2.dart';

/// Picks the icon and accent. The surface stays the same dark card — a
/// full-bleed red or green bar is the brightness hard rule 3 avoids.
enum SdSnackBarKindV2 { success, error, info }

/// The one way to show a snackbar; never call `showSnackBar` directly.
/// Takes an already-localized string.
final class SdSnackBarUtilsV2 {
  /// Something the user asked for completed.
  static void success(BuildContext context, String message) =>
      _show(context, message, SdSnackBarKindV2.success);

  /// Something failed and the user may need to act.
  static void error(BuildContext context, String message) =>
      _show(context, message, SdSnackBarKindV2.error);

  /// Neutral confirmation — a value was noted, a job was queued.
  static void info(BuildContext context, String message) =>
      _show(context, message, SdSnackBarKindV2.info);

  static void _show(
    BuildContext context,
    String message,
    SdSnackBarKindV2 kind,
  ) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger
      // One at a time: a queue replays stale state after the screen moved on.
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: _AppSnackBarBody(message: message, kind: kind),
          // The body draws the card; the SnackBar only positions it.
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            SdSpacingV2.w16,
            0,
            SdSpacingV2.w16,
            SdSpacingV2.h16,
          ),
          // Errors need reading; the rest are just acknowledgements.
          duration: kind == SdSnackBarKindV2.error
              ? const Duration(seconds: 5)
              : const Duration(seconds: 3),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }
}

class _AppSnackBarBody extends StatelessWidget {
  const _AppSnackBarBody({required this.message, required this.kind});

  final String message;
  final SdSnackBarKindV2 kind;

  ({IconData icon, Color accent}) _style(BuildContext context) =>
      switch (kind) {
    SdSnackBarKindV2.success => (
      icon: Icons.check_circle_outline,
      accent: context.colorScheme.secondary,
    ),
    SdSnackBarKindV2.error => (
      icon: Icons.error_outline,
      accent: context.colorScheme.error,
    ),
    SdSnackBarKindV2.info => (
      icon: Icons.info_outline,
      accent: context.colorScheme.primary,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final ({IconData icon, Color accent}) style = _style(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SdSpacingV2.w16,
        vertical: SdSpacingV2.h12,
      ),
      decoration: BoxDecoration(
        color: context.sdTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(SdSpacingV2.r16),
        // Accent as a hairline, not a fill. The icon carries the kind too,
        // so colour is never the only signal.
        border: Border.all(color: style.accent.withValues(alpha: 0.4)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.sdTheme.background.withValues(alpha: 0.5),
            blurRadius: SdSpacingV2.r12,
            offset: Offset(0, SdSpacingV2.h4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          SdIconV2(
            icon: style.icon,
            size: SdSpacingV2.r20,
            color: style.accent,
          ),
          SizedBox(width: SdSpacingV2.w12),
          Expanded(child: Text(message, style: context.textTheme.bodyMedium!)),
        ],
      ),
    );
  }
}
