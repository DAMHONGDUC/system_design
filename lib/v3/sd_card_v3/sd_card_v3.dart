import 'package:flutter/material.dart';

import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';

/// Which layer a card sits on — a prop, never a named constructor.
///
/// - [surface] — the default: a card on the page background.
/// - [elevated] — a card that must stay visible while sitting *on* another
///   card, a sheet or a dialog.
/// - [sunken] — a well that holds content rather than floating above it: a
///   read-only summary block inside a form, a photo tray.
enum SdCardLayerV3 { surface, elevated, sunken }

/// The one card surface in v3 — feature code never builds its own
/// [Container] with a radius and a border.
///
/// The card owns its background, radius, border and padding, and nothing
/// else: no title slot, no trailing chevron, no icon. Those are composition,
/// and a card that grew them would end up with a boolean per screen that
/// wanted a different arrangement.
///
/// **Border, not shadow.** v3 ships light as well as dark, and a shadow tuned
/// for one reads as dirt in the other; a hairline border separates a card from
/// its background identically in both. [SdThemeV3.border] is the only edge in
/// the system.
class SdCardV3 extends StatelessWidget {
  const SdCardV3({
    required this.child,
    this.layer = SdCardLayerV3.surface,
    this.padding,
    this.onTap,
    this.borderColor,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final SdCardLayerV3 layer;

  /// Defaults to [SdContentPaddingV3.card]. Pass [EdgeInsets.zero] for a card
  /// whose child bleeds to the edge — a photo, a list of rows that bring
  /// their own insets.
  final EdgeInsets? padding;

  /// Makes the whole card one tap target. Null leaves it inert, and no ripple
  /// is installed at all — an inert card that ripples is a promise the screen
  /// does not keep.
  final VoidCallback? onTap;

  /// Overrides [SdThemeV3.border] to tint the edge — a card carrying a status
  /// the rest of its content also states (a failed sync, an expiring offer).
  /// Colour is never the only signal, so a tinted border always accompanies a
  /// badge or a label saying the same thing.
  final Color? borderColor;

  /// Set when the card is tappable and its content does not already say what
  /// tapping it does.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Color background = switch (layer) {
      SdCardLayerV3.surface => context.colorScheme3.surface,
      SdCardLayerV3.elevated => context.sdTheme3.surfaceElevated,
      SdCardLayerV3.sunken => context.sdTheme3.surfaceSunken,
    };

    final Widget body = Padding(
      padding: padding ?? SdContentPaddingV3.card,
      child: child,
    );

    return Material(
      color: background,
      borderRadius: SdRadiusV3.cardAll,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: SdRadiusV3.cardAll,
          border: Border.all(color: borderColor ?? context.sdTheme3.border),
        ),
        child: onTap == null
            ? body
            : Semantics(
                button: true,
                label: semanticLabel,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: SdRadiusV3.cardAll,
                  child: body,
                ),
              ),
      ),
    );
  }
}
