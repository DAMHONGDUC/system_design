import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';

/// Which surface a card sits on. The look is a prop, never a named
/// constructor, so two cards of different depth read as one component.
enum SdCardSurfaceV2 {
  /// A card on the screen background — what almost every card is.
  base,

  /// A card sitting *on* another card. One step up, so the nearer layer stays
  /// readable against the one behind it.
  elevated,
}

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
///
/// Pass [borderColor] for a card that has to be picked out of a stack of
/// identical ones — an offer among readouts, say. It is an outline over the
/// card's own edge, drawn at [borderWidth], and it changes nothing else.
///
/// Pass [fillColor] to tint that same card. It is the pair to [borderColor],
/// not a way to give a card its own colour: the two are meant to arrive
/// together, one accent at a low alpha inside a hairline of the same accent
/// at a higher one.
///
/// Pass [gradient] for the rare card that has to be the loudest thing on its
/// screen. It replaces the flat [surface] colour and nothing else — the
/// radius, the clip and the ink are the same, so a gradient card is still the
/// same component and cannot drift into a second kind of card.
class SdCardV2 extends StatelessWidget {
  const SdCardV2({
    required this.child,
    this.onTap,
    this.surface = SdCardSurfaceV2.base,
    this.gradient,
    this.borderColor,
    this.fillColor,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Which depth this card sits at. Defaults to [SdCardSurfaceV2.base].
  ///
  /// Ignored when [gradient] is set, which paints the surface itself.
  final SdCardSurfaceV2 surface;

  /// A fill for the card instead of [surface]'s flat colour.
  ///
  /// **The colours are the app's, not this package's** — a gradient is a
  /// brand decision and the design system holds no brand. Keep it quiet:
  /// hard rule 3 (this app's users are photophobic) means a card may be
  /// distinct without being bright, so a tint of one accent over the card
  /// colour, never two saturated hues meeting.
  final Gradient? gradient;

  /// An outline in this colour around the card. Null — the default — is a
  /// card with no edge at all, which is what almost every card is.
  ///
  /// **The colour is the app's, not this package's**, same as [gradient]: an
  /// accent is a brand decision. Keep it to one hue; hard rule 3's users are
  /// photophobic and a card may be picked out without being bright.
  final Color? borderColor;

  /// Replaces [surface]'s flat colour with this one. Null — the default — is
  /// the one card colour every other card wears.
  ///
  /// **A translucent tint of an app accent, never a second opaque card
  /// colour.** Pass it at a low alpha so what shows through is the screen
  /// behind, which is what keeps a tinted card reading as the same component
  /// rather than as a panel of its own. Ignored when [gradient] paints the
  /// surface itself.
  final Color? fillColor;

  /// The corner every card in the app wears.
  static double get radius => SdSpacingConstant.r16;

  /// How thick [borderColor] draws — a hairline, the same line
  /// `SdDividerV2` is. Two was tried first and read as a frame drawn around
  /// the card rather than as the card's own edge; an outline that has to be
  /// quiet gets its quiet from the colour's alpha, not from more pixels.
  static double get borderWidth => SdSpacingConstant.h1;

  @override
  Widget build(BuildContext context) {
    final BorderRadius shape = BorderRadius.circular(radius);
    final Color color =
        fillColor ??
        switch (surface) {
          SdCardSurfaceV2.base => context.colorScheme.surface,
          SdCardSurfaceV2.elevated => context.sdTheme.surfaceElevated,
        };

    // Transparent over the gradient rather than beside it: `Material` takes a
    // colour, not a `Decoration`, so the fill is painted underneath and the
    // ink still splashes on top of it.
    final Widget surfaceLayer = Material(
      color: gradient == null ? color : Colors.transparent,
      borderRadius: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? child
          : InkWell(onTap: onTap, borderRadius: shape, child: child),
    );

    Widget card = surfaceLayer;

    if (gradient case final Gradient fill) {
      card = DecoratedBox(
        decoration: BoxDecoration(gradient: fill, borderRadius: shape),
        child: card,
      );
    }

    // In the foreground, and last: the fill is a Material that clips its own
    // ink, so an edge painted behind it is an edge the card covers up.
    if (borderColor case final Color colour) {
      card = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(color: colour, width: borderWidth),
          borderRadius: shape,
        ),
        child: card,
      );
    }

    return card;
  }
}
