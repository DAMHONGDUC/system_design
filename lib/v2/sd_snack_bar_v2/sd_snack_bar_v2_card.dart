part of 'sd_snack_bar_v2.dart';

/// The card itself: dark surface, accent hairline, icon then message.
///
/// Public so a host app's tests have something stable to look for — the
/// presenter is a static call, so there is no other handle on what it drew.
class SdSnackBarCardV2 extends StatelessWidget {
  const SdSnackBarCardV2({
    required this.message,
    required this.kind,
    super.key,
  });

  final String message;
  final SdSnackBarKindV2 kind;

  ({IconData icon, Color accent}) _style(BuildContext context) =>
      switch (kind) {
        SdSnackBarKindV2.success => (
          icon: Symbols.check_circle_rounded,
          accent: context.colorScheme.secondary,
        ),
        SdSnackBarKindV2.error => (
          icon: Symbols.error_rounded,
          accent: context.colorScheme.error,
        ),
        SdSnackBarKindV2.info => (
          icon: Symbols.info_rounded,
          accent: context.colorScheme.primary,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final ({IconData icon, Color accent}) style = _style(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SdSpacingConstant.w16,
        vertical: SdSpacingConstant.h12,
      ),
      decoration: BoxDecoration(
        color: context.sdTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(SdSpacingConstant.r16),
        // Accent as a hairline, not a fill — the icon carries the kind too, so colour is never the only signal.
        border: Border.all(color: style.accent.withValues(alpha: 0.4)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.sdTheme.background.withValues(alpha: 0.5),
            blurRadius: SdSpacingConstant.r12,
            offset: Offset(0, SdSpacingConstant.h4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          SdIconV2(
            icon: style.icon,
            size: SdSpacingConstant.r20,
            color: style.accent,
          ),
          SizedBox(width: SdSpacingConstant.w12),
          Expanded(child: Text(message, style: context.textTheme.bodyMedium!)),
        ],
      ),
    );
  }
}
