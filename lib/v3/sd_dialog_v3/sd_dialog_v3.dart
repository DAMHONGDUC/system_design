import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_button_v3/sd_button_v3.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_elevation_v3/sd_elevation_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// One choice in a dialog.
///
/// [isDestructive] picks the destructive button look — the confirm on a
/// delete reads red, and the cancel beside it does not.
class SdDialogActionV3 {
  const SdDialogActionV3({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isPrimary = false,
  });

  final String label;

  /// Called after the dialog closes, so a caller does not have to pop first.
  final VoidCallback onPressed;

  final bool isDestructive;
  final bool isPrimary;
}

/// The app's one confirmation dialog.
///
/// Takes finished strings — this package holds none (`WIDGET_RULES.md` §1).
/// Actions stack vertically rather than sitting in a row: a destructive
/// confirm and its cancel read as two decisions when they are stacked and as
/// one toggle when they are side by side, and the wider label is the one that
/// gets truncated in a row.
class SdDialogV3 extends StatelessWidget {
  const SdDialogV3({
    required this.title,
    required this.actions,
    this.message,
    this.icon,
    super.key,
  });

  final String title;
  final String? message;

  /// A glyph above the title. Set it when the dialog is a warning — colour is
  /// never the only signal.
  final IconData? icon;

  final List<SdDialogActionV3> actions;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.symmetric(
      horizontal: SdContentPaddingV3.horizontal,
    ),
    child: Container(
      padding: SdContentPaddingV3.card,
      decoration: BoxDecoration(
        color: context.sdTheme3.surfaceModal,
        borderRadius: SdRadiusV3.cardAll,
        border: Border.all(color: context.sdTheme3.border),
        boxShadow: SdElevationV3.modal(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            SdIconV3(
              icon!,
              size: SdIconV3.largeSize,
              color: context.sdTheme3.warning,
            ),
            SizedBox(height: SdSpacingConstant.h12),
          ],
          Text(
            title,
            style: context.textTheme3.titleMedium!.semiBold3.copyWith(
              color: context.sdTheme3.textPrimary,
            ),
          ),
          if (message != null) ...<Widget>[
            SizedBox(height: SdSpacingConstant.h8),
            Text(
              message!,
              style: context.textTheme3.bodyMedium!.muted3(context),
            ),
          ],
          SizedBox(height: SdSpacingConstant.h24),
          for (final SdDialogActionV3 action in actions) ...<Widget>[
            SdButtonV3(
              variant: action.isDestructive
                  ? SdButtonVariantV3.destructive
                  : action.isPrimary
                  ? SdButtonVariantV3.primary
                  : SdButtonVariantV3.text,
              label: action.label,
              expand: true,
              onPressed: () {
                // Closed first, then acted on: an action that pushes a route
                // would otherwise leave this dialog sitting under it.
                Navigator.of(context).pop();
                action.onPressed();
              },
            ),
            if (action != actions.last) SizedBox(height: SdSpacingConstant.h8),
          ],
        ],
      ),
    ),
  );
}

/// Show [dialog] over everything, including the floating tab bar.
///
/// A sanctioned top-level presenter (`WIDGET_RULES.md` §5). Uses the root
/// navigator so a dialog raised from inside a tab covers the whole app rather
/// than one branch of it.
Future<void> showSdDialogV3(BuildContext context, SdDialogV3 dialog) =>
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierColor: context.sdTheme3.barrier,
      builder: (BuildContext context) => dialog,
    );
