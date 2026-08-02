import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_icon_v2/sd_icon_v2.dart';

/// What a button *means*, passed to [SdButtonV2] as a prop — never a named
/// constructor per variant.
///
/// - [primary] — the main CTA of a screen/dialog (filled).
/// - [secondary] — supporting action, tonal fill (option tiles, "Unlock"
///   teasers).
/// - [outlined] — alternative action next to a primary.
/// - [text] — low-emphasis action (dialog "Cancel", "Not now").
/// - [destructive] — irreversible confirm (delete); error-tinted fill so it
///   can never be mistaken for the safe action.
/// - [positive] — an affirmative, additive action (add an item); teal-tinted
///   fill so it reads as the "good news" option next to a destructive one.
enum SdButtonVariantV2 {
  primary,
  secondary,
  outlined,
  text,
  destructive,
  positive,
}

/// Where the [SdButtonV2.icon] sits — a prop, like [SdButtonVariantV2].
///
/// - [inline] — glyph and label travel together as one cluster that
///   shrink-wraps its content, so a longer label pushes the glyph sideways.
///   Right for a button sized by what is in it.
/// - [aligned] — the same centred cluster, but the label sits start-aligned
///   in a slot of [SdButtonV2.alignedLabelWidth], so two stacked buttons put
///   their glyphs on the same x and start their labels on the same x however
///   differently long the labels are. This is what makes the Apple and Google
///   buttons on the login screen read as one pair.
enum SdButtonIconPlacementV2 { inline, aligned }

/// The one button widget for the whole app — feature code never uses raw
/// [FilledButton]/[OutlinedButton]/[TextButton]:
///
/// ```dart
/// SdButtonV2(variant: SdButtonVariantV2.primary, label: ..., onPressed: ...)
/// ```
///
/// With an [icon] the content is always the same shape whatever the variant:
/// a [defaultIconSize] glyph, a fixed [iconGap], then the label. Material's
/// own `.icon` constructors are deliberately not used — they carry their own
/// padding per variant, which is what made the filled Apple button and the
/// outlined Google button sit differently.
class SdButtonV2 extends StatelessWidget {
  const SdButtonV2({
    required this.variant,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconPlacement = SdButtonIconPlacementV2.inline,
    this.iconSize,
    this.compact = false,
    this.labelStyle,
    super.key,
  });

  /// Leading glyph box when a call site does not pass [iconSize] — one size
  /// for every icon in every button, so two buttons stacked on top of each
  /// other line up.
  static double get defaultIconSize => SdSpacingConstant.r20;

  /// Breathing room between the glyph and the label.
  static double get iconGap => SdSpacingConstant.w12;

  /// The label slot under [SdButtonIconPlacementV2.aligned] — wide enough for
  /// the longest sign-in label in either shipped locale ("Continue with
  /// Google", "Đăng nhập bằng Apple") so neither pair has to grow out of it.
  static double get alignedLabelWidth => SdSpacingConstant.w160;

  final SdButtonVariantV2 variant;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SdButtonIconPlacementV2 iconPlacement;

  /// Overrides [defaultIconSize] for a brand glyph that needs its own weight
  /// (Apple's mark reads smaller than Google's in the same box). Pass an
  /// `SdSpacingConstant.r*`, never a raw number.
  ///
  /// Under [SdButtonIconPlacementV2.aligned] this resizes the glyph but not
  /// the slot it is centred in, so optical correction never costs the
  /// alignment; under [SdButtonIconPlacementV2.inline] the glyph is the slot,
  /// and a bigger one pushes the label along.
  final double? iconSize;

  /// Chrome-sized button (app-bar actions): tighter padding and height.
  final bool compact;

  /// Overrides the default M3 label style (e.g. option tiles use
  /// `context.textTheme.titleMedium!`). Left null the button resolves its own,
  /// which is also what keeps the foreground colour per variant.
  final TextStyle? labelStyle;

  ButtonStyle? _style(BuildContext context) {
    ButtonStyle? style;

    if (variant == SdButtonVariantV2.destructive) {
      style = FilledButton.styleFrom(
        backgroundColor: context.colorScheme.error,
        foregroundColor: context.colorScheme.onPrimary,
      );
    }
    if (variant == SdButtonVariantV2.positive) {
      style = FilledButton.styleFrom(
        backgroundColor: context.colorScheme.secondary,
        foregroundColor: context.colorScheme.onPrimary,
      );
    }
    if (compact) {
      style = ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: SdSpacingConstant.w14),
        ),
        minimumSize: WidgetStatePropertyAll(Size(0, SdSpacingConstant.h34)),
        visualDensity: VisualDensity.compact,
      ).merge(style);
    }
    return style;
  }

  Widget _label(TextAlign align) =>
      Text(label, style: labelStyle, textAlign: align);

  Widget _child() {
    if (icon == null) return _label(TextAlign.center);
    return switch (iconPlacement) {
      SdButtonIconPlacementV2.inline => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SdIconV2(icon: icon!, size: iconSize ?? defaultIconSize),
          SizedBox(width: iconGap),
          Flexible(child: _label(TextAlign.center)),
        ],
      ),
      // Start-aligned inside a slot that is a minimum, not a fixed width: the
      // labels begin on the same x, and one too long for the slot takes the
      // room it needs (losing the alignment) rather than being cut off.
      SdButtonIconPlacementV2.aligned => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The slot keeps [defaultIconSize] whatever the glyph measures, so
          // an optically-corrected mark cannot shift the pair out of line.
          SizedBox.square(
            dimension: defaultIconSize,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SdIconV2(icon: icon!, size: iconSize ?? defaultIconSize),
            ),
          ),
          SizedBox(width: iconGap),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: alignedLabelWidth),
              child: _label(TextAlign.start),
            ),
          ),
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle? style = _style(context);
    final Widget child = _child();

    return switch (variant) {
      SdButtonVariantV2.primary ||
      SdButtonVariantV2.destructive ||
      SdButtonVariantV2.positive => FilledButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      SdButtonVariantV2.secondary => FilledButton.tonal(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      SdButtonVariantV2.outlined => OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      SdButtonVariantV2.text => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    };
  }
}
