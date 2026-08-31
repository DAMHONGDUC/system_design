import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

final class SdContentPaddingV4 {
  static const double _largeTextScale = 1.2;

  static double get horizontal => SdSpacingConstant.w16;

  static double get listItemGap => SdSpacingConstant.h12;

  static double catalogCardMaxExtent(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(1);

    return textScale > _largeTextScale
        ? MediaQuery.sizeOf(context).width
        : SdSpacingConstant.w240;
  }

  static EdgeInsets bottomActions(BuildContext context) {
    final MediaQueryData viewData = MediaQueryData.fromView(View.of(context));

    return EdgeInsets.fromLTRB(
      horizontal,
      SdSpacingConstant.h12,
      horizontal,
      math.max(viewData.viewPadding.bottom, SdSpacingConstant.h16),
    );
  }

  static double detailBottom(BuildContext context) {
    final MediaQueryData viewData = MediaQueryData.fromView(View.of(context));

    return math.max(viewData.viewPadding.bottom, SdSpacingConstant.h24);
  }

  static double keyboardInset(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;
}
