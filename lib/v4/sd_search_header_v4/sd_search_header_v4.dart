import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v4/sd_content_padding_v4.dart';

part 'sd_search_header_v4_delegate.dart';

final class SdSearchHeaderMetricsV4 {
  static double get toolbarHeight => SdSpacingConstant.h56;
  static double get fieldGap => SdSpacingConstant.h8;
  static double get expandedFieldHeight => SdSpacingConstant.h56;
  static double get dockedFieldHeight => SdSpacingConstant.h44;
}

/// A pinned app bar that moves one search field into the title row on scroll.
class SdSearchHeaderV4 extends StatelessWidget {
  const SdSearchHeaderV4({
    required this.title,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String title;
  final TextEditingController controller;
  final String label;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
    pinned: true,
    delegate: _SdSearchHeaderDelegateV4(
      topPadding: SdContentPaddingV4.statusBarInset(context),
      title: title,
      controller: controller,
      label: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    ),
  );
}
