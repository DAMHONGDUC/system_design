import 'package:flutter/material.dart';

import '../sd_theme_v3/sd_theme_v3.dart';

/// Shorthand theme accessors for System Design v3 widgets.
///
/// Localization is the host app's business and stays out of this package —
/// there is no `l10n` getter here on purpose.
///
/// The getters carry a `3` suffix ([sdTheme3]) rather than shadowing v2's
/// `sdTheme`: an app mid-migration has both extensions on one `ThemeData`,
/// and a screen that imports the package index would otherwise get whichever
/// generation's extension won the import race.
extension SdContextV3X on BuildContext {
  ThemeData get theme3 => Theme.of(this);
  ColorScheme get colorScheme3 => theme3.colorScheme;
  TextTheme get textTheme3 => theme3.textTheme;

  /// True when the app is rendering its dark palette. Widgets should reach
  /// for a token first — this exists for the handful of cases where a value
  /// genuinely has no token, such as picking an asset variant.
  bool get isDark3 => theme3.brightness == Brightness.dark;

  /// The colour slots [ColorScheme] has no name for.
  ///
  /// Asserts when the host app forgot to register [SdThemeV3] on its
  /// `ThemeData.extensions` — loudly, at the first widget that needs a
  /// colour, rather than silently rendering the wrong one.
  SdThemeV3 get sdTheme3 {
    final SdThemeV3? extension = theme3.extension<SdThemeV3>();

    assert(
      extension != null,
      'SdThemeV3 is missing from ThemeData.extensions. Register it in the '
      "app's theme so System Design v3 widgets can resolve their colours.",
    );

    return extension ?? SdThemeV3.fallback;
  }
}
