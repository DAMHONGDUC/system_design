import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_card_v2/sd_card_v2.dart';
import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_skeleton_v2/sd_skeleton_v2.dart';

/// The shape of a list that has not arrived: [rows] placeholder cards at the
/// gap every list in this generation puts between its items.
///
/// **A fixed count, not "as many as fit".** The point is to say "rows are
/// coming and they are about this big"; measuring the viewport to fill it
/// exactly would be a lot of machinery for a placeholder nobody reads.
///
/// **`SdContentPaddingV2.listItemGap` and `SdCardV2.radius`, like the real
/// list**, so the rows do not shuffle or change shape when the data replaces
/// them.
class SdListSkeletonV2 extends StatelessWidget {
  const SdListSkeletonV2({this.rows = defaultRows, this.rowHeight, super.key});

  /// Enough to read as a list on the shortest screen this generation ships
  /// on, without filling a tall one edge to edge.
  static const int defaultRows = 5;

  /// Roughly a two-line list tile — what a record row usually comes out at.
  static double get defaultRowHeight => SdSpacingConstant.h64;

  final int rows;
  final double? rowHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < rows; i++) ...<Widget>[
          if (i > 0) SizedBox(height: SdContentPaddingV2.listItemGap),
          SdSkeletonV2(
            height: rowHeight ?? defaultRowHeight,
            radius: SdCardV2.radius,
          ),
        ],
      ],
    );
  }
}
