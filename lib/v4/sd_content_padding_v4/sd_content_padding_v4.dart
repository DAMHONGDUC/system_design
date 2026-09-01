import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

final class SdContentPaddingV4 {
  static const double _largeTextScale = 1.2;

  static double get horizontal => SdSpacingConstant.w16;

  static double statusBarInset(BuildContext context) =>
      MediaQueryData.fromView(View.of(context)).viewPadding.top;

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

  static double navBarOffset(BuildContext context) {
    final double safeBottom = _viewBottom(context);

    return math.min(
      math.max(safeBottom, minNavBarOffset),
      maxNavBarOffset,
    );
  }

  /// The floor under [navBarOffset]. Below this the bar reads as stuck to the
  /// bottom edge, whatever the device claims it needs.
  static double get minNavBarOffset => SdSpacingConstant.h16;

  /// The ceiling over [navBarOffset]. Above this the bar reads as floating
  /// away from the bottom rather than sitting at it.
  static double get maxNavBarOffset => SdSpacingConstant.h20;

  static double _viewBottom(BuildContext context) {
    final MediaQueryData viewData = MediaQueryData.fromView(View.of(context));

    return viewData.viewPadding.bottom;
  }

  static double keyboardInset(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;
}
