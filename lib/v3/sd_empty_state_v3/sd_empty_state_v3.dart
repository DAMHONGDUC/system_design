import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The one widget for "there is nothing here" — and, with [SdEmptyStateV3]'s
/// [action], for "there is nothing here *yet*".
///
/// **Empty and error are the same shape on purpose.** A failed load and an
/// empty list occupy the same slot in a screen, and giving them two different
/// layouts means every list builds two branches that drift apart. The tone is
/// carried by the [icon] and the [message], and the recovery by [action] —
/// "Add your first item" and "Try again" are the same widget in the same
/// place.
///
/// A list must never render this and a spinner at once: a screen that has not
/// loaded is not empty, and saying so flashes "No items" at a seller who has
/// four hundred.
class SdEmptyStateV3 extends StatelessWidget {
  const SdEmptyStateV3({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;

  /// One sentence saying what to do about it. Optional — "No results for
  /// 'xyz'" needs no elaboration.
  final String? message;

  /// The recovery. Pass an `SdButtonV3`; this widget does not grow its own
  /// button style.
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SdContentPaddingV3.horizontal,
        vertical: SdSpacingConstant.h32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SdIconV3(
            icon,
            size: SdSpacingConstant.r44,
            color: context.sdTheme3.textTertiary,
          ),
          SizedBox(height: SdSpacingConstant.h16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme3.titleMedium!.semiBold3.copyWith(
              color: context.sdTheme3.textPrimary,
            ),
          ),
          if (message != null) ...<Widget>[
            SizedBox(height: SdSpacingConstant.h8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: context.textTheme3.bodyMedium!.muted3(context),
            ),
          ],
          if (action != null) ...<Widget>[
            SizedBox(height: SdSpacingConstant.h24),
            action!,
          ],
        ],
      ),
    ),
  );
}
