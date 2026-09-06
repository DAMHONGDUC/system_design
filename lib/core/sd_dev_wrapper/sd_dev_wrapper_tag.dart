part of 'sd_dev_wrapper.dart';

/// The strip itself: one rotated line of text on a slab, clipped to the left
/// edge of the screen.
class _SdDevWrapperTag extends StatelessWidget {
  const _SdDevWrapperTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        right: Radius.circular(_SdDevWrapperConstant.radius),
      ),
      child: ColoredBox(
        color: _SdDevWrapperConstant.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _SdDevWrapperConstant.paddingCross,
            vertical: _SdDevWrapperConstant.paddingAlong,
          ),
          // Reads bottom-to-top, so the strip stays a strip: a horizontal
          // banner long enough to hold a version covers real UI.
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: _SdDevWrapperConstant.foreground,
                fontSize: _SdDevWrapperConstant.fontSize,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: _SdDevWrapperConstant.letterSpacing,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// What the strip is made of.
///
/// **Literal values on purpose**, and the one place in this package that is
/// allowed them: [SdDevWrapper] renders above the app's theme, where no token
/// exists yet, and a tag that borrows the app's colours is a tag that vanishes
/// when those colours are the bug.
final class _SdDevWrapperConstant {
  static const Color background = Color(0xE6101114);
  static const Color foreground = Color(0xFFFFC24B);
  static const double fontSize = 10;
  static const double letterSpacing = 0.8;
  static const double paddingAlong = 8;
  static const double paddingCross = 3;
  static const double radius = 4;
  static const String separator = ' · ';
}
