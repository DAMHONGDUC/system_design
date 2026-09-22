import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_button_v3/sd_button_v3.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_motion_v3/sd_motion_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// "Continue with Apple", "Continue with Google" — a third-party sign-in
/// button, and the only shape they may wear.
///
/// **Its own widget rather than a variant of [SdButtonV3], because the mark is
/// sized from the label rather than from the button.** A generic button scales
/// its icon with its padding, which is right for a glyph that decorates a
/// verb and wrong for a logo that has to sit level with the words beside it:
/// at the size the login screen used, the Apple mark drew visibly shorter than
/// the cap height of "Continue with Apple" and the pair read as a mistake.
/// Here the mark is derived from the label's own font size, so the two stay in
/// proportion whatever the text scale does to them.
///
/// **The colours are still [SdButtonVariantV3.vendor]'s**, read through
/// [SdButtonStyleV3] rather than restated: Apple allows its button in black,
/// white, or white with an outline and nothing else, and one owner for that
/// pair is what stops a theme change re-tinting somebody else's trademark.
///
/// **[leading] is the slot the vendors' own artwork drops into.** A glyph is a
/// redrawn trademark and does not pass review, so a shipping build passes the
/// real files here — and because the box is the same square either way, the
/// swap changes nothing about the layout.
class SdVendorButtonV3 extends StatelessWidget {
  const SdVendorButtonV3({
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.busy = false,
    super.key,
  }) : assert(
         icon == null || leading == null,
         'A vendor button carries one mark: a glyph or the artwork, never both.',
       );

  final String label;

  /// A glyph stand-in, for development. Ships as [leading].
  final IconData? icon;

  /// The vendor's own artwork, boxed to [markSizeFor] and never tinted — the
  /// Google "G" is four colours and stays that way.
  final Widget? leading;

  final bool busy;

  final VoidCallback? onPressed;

  /// **Apple's floor, in logical points, and it is a requirement rather than
  /// a preference** — a sign-in button below it is a review finding.
  ///
  /// It is a floor, not the height: [SdContentPaddingV3.button] gives this
  /// button its size the way it gives every other button its size, and on
  /// every window this app ships in that already clears 44. The constraint is
  /// here so a future change to the padding cannot quietly drop under it, and
  /// `sd_vendor_button_v3_test.dart` fails if it does.
  static const double minHeight = 44;

  /// **[SdButtonSizeV3.small]'s padding, not the full-size one.** These two
  /// sit at the bottom of a screen whose job is to be read, so they are
  /// compact by design — a taller pair pushed the privacy line off the fold
  /// on a small phone and made the page feel like a form.
  ///
  /// Read through the enum rather than restated, so "small" means one thing.
  /// [minHeight] is what stops the compact scale dropping under Apple's
  /// floor, which at this scale it otherwise would.
  static EdgeInsets get padding =>
      SdContentPaddingV3.button * SdButtonSizeV3.small.scale;

  /// The mark's box, from the label's font size.
  ///
  /// A little over the text, because a glyph never fills its own box: at 1:1
  /// the logo reads short against the letters, which is exactly what this
  /// widget exists to fix. The ratio is the number to change if a vendor
  /// publishes artwork with different bearings.
  static double markSizeFor(double fontSize) => fontSize * markRatio;

  static const double markRatio = 1.35;

  /// Wider than a plain button's icon gap. A logo is a separate object from
  /// the words — the vendors set it apart in their own buttons — and the
  /// tighter gap made the mark look like a letter of the label.
  static double get markGap => SdSpacingConstant.w12;

  bool get _enabled => onPressed != null && !busy;

  @override
  Widget build(BuildContext context) {
    final SdButtonStyleV3 style = SdButtonStyleV3.of(
      context,
      SdButtonVariantV3.vendor,
    );
    final TextStyle labelStyle = context.textTheme3.labelLarge!.semiBold3
        .copyWith(color: style.foreground);
    final double markSize = markSizeFor(labelStyle.fontSize ?? markRatio);

    // **Always full width, never a hugging button.** Both vendors draw their
    // sign-in button edge to edge, and the pair has to be one column of two
    // equal rows — a button that sized to its own label would make "Continue
    // with Google" wider than "Continue with Apple".
    final Widget content = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox.square(
          dimension: markSize,
          child: icon != null
              ? SdIconV3(icon!, size: markSize, color: labelStyle.color)
              : leading,
        ),
        SizedBox(width: markGap),
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: padding,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Invisible rather than removed: the button must not change
                    // size when a sign-in starts, and this one is full width, so
                    // a reflow here moves the other button too.
                    Opacity(opacity: busy ? 0 : 1, child: content),
                    if (busy)
                      SizedBox.square(
                        dimension: markSize,
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
