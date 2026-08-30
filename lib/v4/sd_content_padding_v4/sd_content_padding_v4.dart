import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

final class SdContentPaddingV4 {
  static double get horizontal => SdSpacingConstant.w16;

  static double get listItemGap => SdSpacingConstant.h12;

  static double detailBottom(BuildContext context) {
    final MediaQueryData viewData = MediaQueryData.fromView(View.of(context));

    return math.max(viewData.viewPadding.bottom, SdSpacingConstant.h24);
  }

  static double keyboardInset(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;
}
