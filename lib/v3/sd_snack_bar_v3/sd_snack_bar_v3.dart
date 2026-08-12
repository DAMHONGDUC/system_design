import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_elevation_v3/sd_elevation_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';

part 'sd_snack_bar_v3_card.dart';
part 'sd_snack_bar_v3_host.dart';

/// What a message is telling the user.
///
/// **The glyph changes with the accent, never only the colour.** A message
/// distinguished by hue alone is unreadable to a colour-blind seller and
/// invisible in a photograph of a screen.
enum SdSnackBarKindV3 { success, error, info }

/// Which edge the message comes from.
///
/// [bottom] is what every screen wants. [top] is for a route that owns the
/// bottom of the screen — a sheet with a pinned action row, where a message
/// rising from below would land under the seller's thumb.
enum SdSnackBarPlacementV3 { bottom, top }

/// The app's one way to show a transient message.
///
/// **It draws into the root [Overlay], not a [ScaffoldMessenger]**, and that
/// is the whole reason it exists. A messenger renders into the nearest
/// registered [Scaffold], so a message raised from inside a bottom sheet or a
/// dialog goes to the screen *underneath* — where the very sheet that raised
/// it covers it up. Widget tests do not catch that: `find.text` matches a
/// widget the user cannot see.
///
/// One message at a time. A second call replaces the first rather than
/// queueing behind it: the newer message is the one the seller's last action
/// produced, and a queue means watching two seconds of stale news first.
///
/// Pass a finished, localized string — this package holds no strings
/// (`WIDGET_RULES.md` §1).
final class SdSnackBarUtilsV3 {
  /// The entry currently on screen, if any. Static because there is one
  /// overlay and one message at a time.
  static OverlayEntry? _current;

  static void success(
    BuildContext context,
    String message, {
    SdSnackBarPlacementV3 placement = SdSnackBarPlacementV3.bottom,
  }) => _show(context, message, SdSnackBarKindV3.success, placement);

  static void error(
    BuildContext context,
    String message, {
    SdSnackBarPlacementV3 placement = SdSnackBarPlacementV3.bottom,
  }) => _show(context, message, SdSnackBarKindV3.error, placement);

  static void info(
    BuildContext context,
    String message, {
    SdSnackBarPlacementV3 placement = SdSnackBarPlacementV3.bottom,
  }) => _show(context, message, SdSnackBarKindV3.info, placement);

  /// Take down whatever is showing. Called when a route that raised a message
  /// is itself dismissed.
  static void dismiss() {
    _current?.remove();
    _current = null;
  }

  static void _show(
    BuildContext context,
    String message,
    SdSnackBarKindV3 kind,
    SdSnackBarPlacementV3 placement,
  ) {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);

    if (overlay == null) return;

    dismiss();

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) => _SdSnackBarHostV3(
        message: message,
        kind: kind,
        placement: placement,
        onDismissed: dismiss,
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }
}
