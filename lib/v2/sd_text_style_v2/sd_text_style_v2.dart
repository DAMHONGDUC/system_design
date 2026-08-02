import 'package:flutter/material.dart';

import '../sd_context_v2/sd_context_v2.dart';

/// The two tweaks System Design widgets make to a text style from
/// `context.textTheme`. Anything else goes through `copyWith` at the call
/// site — these two are here because they repeat everywhere.
extension SdTextStyleV2X on TextStyle {
  /// Semi-bold. Named `semiBold`, not `w600`, so it never collides with a
  /// host app's own TextStyle extension.
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// The muted colour for captions and subtitles.
  TextStyle muted(BuildContext context) =>
      copyWith(color: context.sdTheme.textSecondary);
}
