import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// What a button *means*, passed to [SdButtonV3] as a prop — never a named
/// constructor per variant.
///
/// - [primary] — the main CTA of a screen, sheet or dialog (filled).
/// - [secondary] — a supporting action, tonal fill.
/// - [outlined] — an alternative action sitting next to a primary.
/// - [text] — low-emphasis ("Cancel", "Not now", "Skip").
/// - [destructive] — an irreversible confirm (delete, archive-all); error
///   fill so it can never be mistaken for the safe action.
enum SdButtonVariantV3 { primary, secondary, outlined, text, destructive }

/// Size of an [SdButtonV3] — a prop, like [SdButtonVariantV3]. [scale]
/// multiplies the shared padding, icon and icon gap around one baseline, so a
/// small button is a smaller version of the same shape rather than a
/// differently-proportioned one.
enum SdButtonSizeV3 {
  small,
  medium,
  large;

  double get scale => switch (this) {
    SdButtonSizeV3.small => 0.75,
    SdButtonSizeV3.medium => 1,
    SdButtonSizeV3.large => 1.25,
  };
}

/// The one button widget for the whole app — feature code never uses raw
/// [FilledButton] / [OutlinedButton] / [TextButton]:
///
/// ```dart
/// SdButtonV3(variant: SdButtonVariantV3.primary, label: ..., onPressed: ...)
/// ```
///
/// Every variant wears the same [SdContentPaddingV3.button] and centres its
/// content, so a filled and an outlined button standing next to each other are
/// the same size. Material's own `.icon` constructors are deliberately not
/// used: they carry their own padding *per variant*, which is exactly what
/// makes two buttons in a row sit differently.
///
/// **[busy] is why this widget exists rather than a styled [FilledButton].**
/// Almost every button in Seller OS writes to Firestore, so almost every one
/// needs a pending state, and the naive version — swapping the label for a
/// spinner — makes the button resize mid-tap and shifts the whole row. Here
/// the spinner is drawn *over* the label in a [Stack] and the label is only
/// made invisible, so the button keeps its exact width for the whole round
/// trip. [busy] also disables the button, so a double tap cannot post twice.
class SdButtonV3 extends StatelessWidget {
  const SdButtonV3({
    required this.variant,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.size = SdButtonSizeV3.medium,
    this.busy = false,
    this.expand = false,
    super.key,
  }) : assert(
         icon == null || leading == null,
         'Pass icon or leading, never both — they occupy the same slot.',
       );

  final SdButtonVariantV3 variant;
  final String label;

  /// Null disables the button. So does [busy] — a caller does not have to
  /// null this out while a save is in flight.
  final VoidCallback? onPressed;

  final IconData? icon;

  /// Artwork in [icon]'s slot, for a mark that cannot be an [IconData] — a
  /// vendor brand logo, which Apple and Google both supply and forbid
  /// redrawing. Boxed to the icon size, and never tinted: the Google "G" is
  /// four colours and stays that way.
  final Widget? leading;

  final SdButtonSizeV3 size;

  /// Shows a spinner over the label and blocks further taps, without changing
  /// the button's size. See the class doc.
  final bool busy;

  /// Stretches to the width of the parent — a sheet's confirm, a form's save.
  /// Off by default: a button that fills its row by accident is the most
  /// common way a screen stops looking deliberate.
  final bool expand;

  /// Breathing room between the glyph and the label, before [size] scales it.
  static double get iconGap => SdSpacingConstant.w8;

  bool get _enabled => onPressed != null && !busy;

  @override
  Widget build(BuildContext context) {
    final SdButtonStyleV3 style = SdButtonStyleV3.of(context, variant);
    final double scale = size.scale;
    final EdgeInsets padding = SdContentPaddingV3.button * scale;
    final double glyphSize = SdIconV3.defaultSize * scale;
    final TextStyle labelStyle = context.textTheme3.labelLarge!.semiBold3
        .copyWith(
          color: _enabled ? style.foreground : style.disabledForeground,
        );

    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          SdIconV3(icon!, size: glyphSize, color: labelStyle.color),
          SizedBox(width: iconGap * scale),
        ] else if (leading != null) ...<Widget>[
          // Boxed to the icon size so a logo button and an icon button are
          // the same shape, whatever the artwork's own aspect ratio.
          SizedBox.square(dimension: glyphSize, child: leading),
          SizedBox(width: iconGap * scale),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: AnimatedOpacity(
        duration: SdMotionV3.fast,
        curve: SdMotionV3.standard,
        opacity: _enabled ? 1 : SdButtonStyleV3.disabledOpacity,
        child: Material(
          color: style.background,
          borderRadius: SdRadiusV3.buttonAll,
          child: InkWell(
            onTap: _enabled ? onPressed : null,
            borderRadius: SdRadiusV3.buttonAll,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: SdRadiusV3.buttonAll,
                border: style.border == null
                    ? null
                    : Border.fromBorderSide(style.border!),
              ),
              child: Padding(
                padding: padding,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Invisible rather than removed: the button must not
                    // change width when a save starts. See the class doc.
                    Opacity(opacity: busy ? 0 : 1, child: content),
                    if (busy)
                      SizedBox.square(
                        dimension: SdIconV3.defaultSize * scale,
                        child: CircularProgressIndicator(
                          strokeWidth: SdSpacingConstant.w2,
                          color: style.foreground,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The four colours a [SdButtonVariantV3] resolves to. Its own type so the
/// build method reads as one lookup then one layout, rather than five
/// switches interleaved with widgets.
@immutable
class SdButtonStyleV3 {
  const SdButtonStyleV3({
    required this.background,
    required this.foreground,
    required this.disabledForeground,
    this.border,
  });

  /// How far a disabled button fades. Colour alone is not allowed to be the
  /// only signal (a disabled primary is still a saturated fill), so the
  /// opacity change carries it too.
  static const double disabledOpacity = 0.45;

  final Color background;
  final Color foreground;
  final Color disabledForeground;
  final BorderSide? border;

  static SdButtonStyleV3 of(BuildContext context, SdButtonVariantV3 variant) {
    final ColorScheme colors = context.colorScheme3;
    final Color muted = context.sdTheme3.textSecondary;

    return switch (variant) {
      SdButtonVariantV3.primary => SdButtonStyleV3(
        background: colors.primary,
        foreground: colors.onPrimary,
        disabledForeground: colors.onPrimary,
      ),
      SdButtonVariantV3.secondary => SdButtonStyleV3(
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        disabledForeground: muted,
      ),
      SdButtonVariantV3.outlined => SdButtonStyleV3(
        background: Colors.transparent,
        foreground: colors.primary,
        disabledForeground: muted,
        border: BorderSide(color: context.sdTheme3.border),
      ),
      SdButtonVariantV3.text => SdButtonStyleV3(
        background: Colors.transparent,
        foreground: colors.primary,
        disabledForeground: muted,
      ),
      SdButtonVariantV3.destructive => SdButtonStyleV3(
        background: colors.error,
        foreground: colors.onError,
        disabledForeground: colors.onError,
      ),
    };
  }
}
