part of 'sd_nav_cell_v3.dart';

/// The glass the shell's navigation chrome is made of, and whether this
/// device can render it.
///
/// The effect is a fragment-shader image filter, and only Impeller can run
/// one: true on iOS, true on Android devices that get the Vulkan backend,
/// false on Android's Skia fallback and in widget tests. When false the
/// chrome renders `FakeGlass` — a flat translucent fill — which keeps the
/// same geometry and legibility without the shader.
///
/// **Shared by the pill and the rail**, because the material is the one thing
/// about them that is not a consequence of which axis they run along.
abstract final class SdGlassV3 {
  static bool? _debugOverride;

  /// Test seam: the widget-test engine is Skia, so [isSupported] is false
  /// there and every test would exercise the fallback instead of the shipped
  /// look.
  @visibleForTesting
  static set debugSupported(bool? value) => _debugOverride = value;

  static bool get isSupported =>
      _debugOverride ?? ImageFilter.isShaderFilterSupported;

  /// The tint inside the one glass surface. Strong enough to read as a
  /// switcher thumb over a light page without becoming a solid button.
  static const double selectedThumbOpacity = 0.22;

  /// Glass tuned from the app's own palette, so the chrome is light over a
  /// light page and dark over a dark one.
  static LiquidGlassSettings settings(BuildContext context) {
    final Color base = context.sdTheme3.background;
    final bool dark = context.isDark3;

    return LiquidGlassSettings(
      glassColor: base.withValues(alpha: dark ? 0.26 : 0.30),
      thickness: 22,
      refractiveIndex: 1.38,
      blur: 15,
      lightIntensity: dark ? 0.9 : 1.45,
      ambientStrength: 0.4,
      chromaticAberration: 0,
      saturation: 1.15,
    );
  }
}
