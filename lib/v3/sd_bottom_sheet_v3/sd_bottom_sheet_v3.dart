import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The chrome every bottom sheet in the app wears: a grab handle, a title,
/// and the caller's content under it.
///
/// The handle is decorative and excluded from semantics — a screen reader
/// announcing "handle" before the sheet's title is noise.
class SdBottomSheetV3 extends StatelessWidget {
  const SdBottomSheetV3({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  /// The grab handle's drawn size. Intrinsic to this widget, so it lives on
  /// it rather than on a spacing class.
  static double get handleWidth => SdSpacingConstant.w40;
  static double get handleHeight => SdSpacingConstant.h4;

  @override
  Widget build(BuildContext context) => Container(
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
      mainAxisSize: MainAxisSize.min,
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
        child,
      ],
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
