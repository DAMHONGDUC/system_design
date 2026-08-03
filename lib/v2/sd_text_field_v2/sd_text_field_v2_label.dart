part of 'sd_text_field_v2.dart';

/// The line above the box. Static, quiet, and always in the same place —
/// whether the field is empty, filled, focused or disabled.
class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SdSpacingConstant.h8),
      child: Text(
        text,
        style: context.textTheme.labelLarge!.semiBold.copyWith(
          color: context.sdTheme.textSecondary,
        ),
      ),
    );
  }
}

/// The line under the box: a hint about the format, or what went wrong.
class _HelperLine extends StatelessWidget {
  const _HelperLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: SdSpacingConstant.h6,
        left: SdSpacingConstant.w4,
      ),
      child: Text(
        text,
        style: context.textTheme.bodySmall!.copyWith(color: color),
      ),
    );
  }
}
