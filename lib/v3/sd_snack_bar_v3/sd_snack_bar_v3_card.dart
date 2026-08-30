part of 'sd_snack_bar_v3.dart';

/// The card a message is drawn on.
///
/// Public because it is the only handle a test has on what a static presenter
/// put on screen — assert on this, not on the text, which would also match a
/// message covered by a sheet.
class SdSnackBarCardV3 extends StatelessWidget {
  const SdSnackBarCardV3({
    required this.message,
    required this.kind,
    super.key,
  });

  final String message;
  final SdSnackBarKindV3 kind;

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (kind) {
      SdSnackBarKindV3.success => context.sdTheme3.success,
      SdSnackBarKindV3.error => context.sdTheme3.danger,
      SdSnackBarKindV3.info => context.sdTheme3.info,
    };

    final IconData glyph = switch (kind) {
      SdSnackBarKindV3.success => Icons.check_circle_rounded,
      SdSnackBarKindV3.error => Icons.error_rounded,
      SdSnackBarKindV3.info => Icons.info_rounded,
    };

    return Container(
      padding: SdContentPaddingV3.card,
      decoration: BoxDecoration(
        color: context.sdTheme3.surfaceModal,
        borderRadius: SdRadiusV3.cardAll,
        border: Border.all(color: accent),
        boxShadow: SdElevationV3.modal(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SdIconV3(glyph, size: SdIconV3.smallSize, color: accent),
          SizedBox(width: SdSpacingConstant.w12),
          Expanded(
            // Capped for the same reason as the v2 card: a message built from
            // an exception is as long as the SDK made it, and the card grew
            // until it ran off the screen.
            child: Text(
              message,
              style: context.textTheme3.bodyMedium!.copyWith(
                color: context.sdTheme3.textPrimary,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
