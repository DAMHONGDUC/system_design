import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_floating_bar_scope_v3/sd_floating_bar_scope_v3.dart';
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
///
/// **[variant] is which slot it is filling**, and it is a look rather than a
/// switch of behaviour: the words, the mark and the recovery are identical,
/// and what changes is the furniture around them.
class SdEmptyStateV3 extends StatelessWidget {
  const SdEmptyStateV3({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.variant = SdEmptyStateVariantV3.page,
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

  /// Whether this owns the screen or sits in one block of it.
  final SdEmptyStateVariantV3 variant;

  /// The furniture around the words.
  ///
  /// **Centred in the band the seller can see, not in the body.** A tab
  /// screen runs its body under the glass nav pill (`extendBody`), so
  /// centring against the full height puts the message low and its last line
  /// behind the bar. Reading the scope means no caller has to remember, and a
  /// pushed route — which has no bar — adds nothing.
  ///
  /// **An inline block pays none of it.** It is one item in a screen that has
  /// other content, so the page's own air and the bar's footprint belong to
  /// whatever owns that screen; charging them here put a hundred points of
  /// dead space under three lines of text and left the block reading as if it
  /// were set too high.
  EdgeInsets _padding(BuildContext context) {
    if (variant == SdEmptyStateVariantV3.inline) return EdgeInsets.zero;

    return EdgeInsets.only(
      left: SdContentPaddingV3.horizontal,
      right: SdContentPaddingV3.horizontal,
      top: SdSpacingConstant.h32,
      bottom:
          SdSpacingConstant.h32 +
          (SdFloatingBarScopeV3.hasBarBelow(context)
              ? SdContentPaddingV3.floatingBarInset(context)
              : 0),
    );
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: _padding(context),
      child: Column(
        // **Min, so the `Center` above has something to centre.** Filled to
        // the height instead, the column *is* the available space and its
        // children sit at the top of it — which is the one thing this widget
        // must never do on a screen it owns.
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

/// Which slot an [SdEmptyStateV3] is filling.
enum SdEmptyStateVariantV3 {
  /// It owns the screen: the page's own top and bottom air, the gutter, and
  /// the floating bar's footprint below it.
  page,

  /// It is one block inside a screen that has other content — a card standing
  /// in for the rows that are not there. Sized to its content, so the
  /// container it sits in decides the air around it.
  inline,
}
