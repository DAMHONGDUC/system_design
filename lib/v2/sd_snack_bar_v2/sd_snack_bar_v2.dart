import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';

part 'sd_snack_bar_v2_card.dart';
part 'sd_snack_bar_v2_host.dart';

/// Picks the icon and accent. The surface stays the same dark card — a
/// full-bleed red or green bar is the brightness hard rule 3 avoids.
enum SdSnackBarKindV2 { success, error, info }

/// Which edge the card comes from.
///
/// [bottom] is the default and what every screen wants. [top] exists for a
/// route that owns the bottom of the screen — a sheet whose own surface would
/// otherwise sit on the message.
enum SdSnackBarPlacementV2 { top, bottom }

/// The one way to show a snackbar; never call `showSnackBar` directly.
/// Takes an already-localized string.
///
/// It draws into the **root overlay**, not a `ScaffoldMessenger`. A messenger
/// renders into the nearest registered `Scaffold`, so a route without one —
/// the paywall sheet — sent its messages to the screen *underneath*, where
/// they were covered by the very sheet that raised them. The overlay is above
/// every route, so there is nothing left to hide behind.
final class SdSnackBarUtilsV2 {
  /// Something the user asked for completed.
  static void success(
    BuildContext context,
    String message, {
    SdSnackBarPlacementV2 placement = SdSnackBarPlacementV2.bottom,
  }) => _show(context, message, SdSnackBarKindV2.success, placement);

  /// Something failed and the user may need to act.
  static void error(
    BuildContext context,
    String message, {
    SdSnackBarPlacementV2 placement = SdSnackBarPlacementV2.bottom,
  }) => _show(context, message, SdSnackBarKindV2.error, placement);

  /// Neutral confirmation — a value was noted, a job was queued.
  static void info(
    BuildContext context,
    String message, {
    SdSnackBarPlacementV2 placement = SdSnackBarPlacementV2.bottom,
  }) => _show(context, message, SdSnackBarKindV2.info, placement);

  /// How long the card stays. Errors need reading; the rest are just
  /// acknowledgements.
  static const Duration errorDuration = Duration(seconds: 5);
  static const Duration duration = Duration(seconds: 3);

  /// One at a time: a queue replays stale state after the screen moved on.
  static OverlayEntry? _current;

  static void _show(
    BuildContext context,
    String message,
    SdSnackBarKindV2 kind,
    SdSnackBarPlacementV2 placement,
  ) {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);

    // No overlay means no Navigator above this context — nothing to draw into,
    // and a message is never worth throwing over.
    if (overlay == null) return;

    _remove();

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (BuildContext _) => _SdSnackBarHostV2(
        message: message,
        kind: kind,
        placement: placement,
        duration: kind == SdSnackBarKindV2.error ? errorDuration : duration,
        onDismissed: () {
          if (identical(_current, entry)) _remove();
        },
        // The overlay went away under us — a popped route, a torn-down test.
        // Only forget the handle; touching an entry whose overlay is gone is
        // what turns one stale message into an assertion in the next screen.
        onDisposed: () {
          if (identical(_current, entry)) _current = null;
        },
      ),
    );
    _current = entry;

    overlay.insert(entry);
  }

  static void _remove() {
    final OverlayEntry? entry = _current;

    _current = null;

    if (entry == null) return;
    if (entry.mounted) entry.remove();

    entry.dispose();
  }
}
