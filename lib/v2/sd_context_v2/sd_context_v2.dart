import 'package:flutter/material.dart';

import '../sd_theme_v2/sd_theme_v2.dart';

/// Shorthand theme accessors for System Design widgets.
///
/// Localization is the host app's business and stays out of this package —
/// there is no `l10n` getter here on purpose.
extension SdContextV2X on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  /// The colour slots `ColorScheme` has no name for.
  ///
  /// Asserts when the host app forgot to register [SdThemeV2] on its
  /// `ThemeData.extensions` — loudly, at the first widget that needs a
  /// colour, rather than silently rendering the wrong one.
  SdThemeV2 get sdTheme {
    final SdThemeV2? extension = theme.extension<SdThemeV2>();

    assert(
      extension != null,
      'SdThemeV2 is missing from ThemeData.extensions. Register it in the '
      "app's theme so System Design widgets can resolve their colours.",
    );

    return extension ?? SdThemeV2.fallback;
  }
}
