import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_keyboard_dismiss_v3/sd_keyboard_dismiss_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The chrome every bottom sheet in the app wears: a grab handle, a title,
/// and the caller's content under it.
///
/// The handle is decorative and excluded from semantics — a screen reader
/// announcing "handle" before the sheet's title is noise.
///
/// **[heightFactor] is what makes it a document rather than a menu.** See
/// that field.
///
/// **[heightFactor] is what makes it a document rather than a menu.** See
/// that field.
///
/// **It wraps its content in [SdKeyboardDismissV3] itself**, and needs to: a
/// sheet is a route of its own, so it is not inside the scaffold underneath it
/// and inherits nothing from that one — and a sheet is where most of this
/// app's typing happens.
class SdBottomSheetV3 extends StatelessWidget {
  const SdBottomSheetV3({
    required this.title,
    required this.child,
    this.heightFactor,
    super.key,
  });

  final String title;
  final Widget child;

  /// How much of the screen the sheet takes, as a fraction.
  ///
  /// **Null sizes the sheet to its content, and that is the default.** A menu
  /// taller than its rows is a sheet with dead space under the thumb that has
  /// to reach past it. A sheet that is *read* rather than chosen from passes
  /// this instead, so its scroll starts at a predictable place and enough of
  /// the page behind stays visible to say the sheet is dismissable.
  ///
  /// A fraction rather than a number of points on purpose: a height typed in
  /// points is a height that is wrong on the next device. The [child] is
  /// stretched to fill whatever is left under the title, so it brings its own
  /// scroll view.
  final double? heightFactor;

  /// The grab handle's drawn size. Intrinsic to this widget, so it lives on
  /// it rather than on a spacing class.
  static double get handleWidth => SdSpacingConstant.w40;
  static double get handleHeight => SdSpacingConstant.h4;

  @override
  Widget build(BuildContext context) => SdKeyboardDismissV3(
    child: SizedBox(
      height: heightFactor == null
          ? null
          : MediaQuery.sizeOf(context).height * heightFactor!,
      child: Container(
        decoration: BoxDecoration(
          color: context.sdTheme3.surfaceModal,
          borderRadius: SdRadiusV3.modalTop,
          border: Border.all(color: context.sdTheme3.border),
        ),
        padding: EdgeInsets.only(
          left: SdContentPaddingV3.horizontal,
          right: SdContentPaddingV3.horizontal,
          top: SdSpacingConstant.h12,
          // - clears the home indicator, because a sheet's last row is the one a
          //   thumb reaches for
          // - lifts over the keyboard, so no caller wraps this in its own Padding
          bottom:
              SdContentPaddingV3.detailBottom(context) +
              SdContentPaddingV3.keyboardInset(context),
        ),
        child: Column(
          // Min sizes the sheet to its rows; max is what lets the Expanded
          // below have space to take.
          mainAxisSize: heightFactor == null
              ? MainAxisSize.min
              : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: ExcludeSemantics(
                child: Container(
                  width: handleWidth,
                  height: handleHeight,
                  decoration: BoxDecoration(
                    color: context.sdTheme3.border,
                    borderRadius: SdRadiusV3.fullAll,
                  ),
                ),
              ),
            ),
            SizedBox(height: SdSpacingConstant.h16),
            Text(
              title,
              style: context.textTheme3.titleMedium!.semiBold3.copyWith(
                color: context.sdTheme3.textPrimary,
              ),
            ),
            SizedBox(height: SdSpacingConstant.h16),
            // Expanded only when a height was asked for: a min-sized Column has
            // no spare space to give, and Expanded inside one throws.
            if (heightFactor == null) child else Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

/// Show a sheet over everything, including the floating tab bar.
///
/// A sanctioned top-level presenter (`WIDGET_RULES.md` §5).
/// **`useRootNavigator: true` is not optional here** — a sheet pushed on a
/// shell branch's own navigator slides *under* the floating glass tab bar,
/// which reads as a rendering bug and puts the sheet's first action beneath
/// it.
Future<T?> showSdBottomSheetV3<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  barrierColor: context.sdTheme3.barrier,
  builder: builder,
);
