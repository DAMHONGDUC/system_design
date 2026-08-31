import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_content_padding_v4/sd_content_padding_v4.dart';
import '../sd_icon_v4/sd_icon_v4.dart';
import '../sd_radius_v4/sd_radius_v4.dart';

class SdBottomSheetV4 extends StatelessWidget {
  const SdBottomSheetV4({
    required this.title,
    required this.closeTooltip,
    required this.child,
    this.heightFactor,
    super.key,
  });

  final String title;
  final String closeTooltip;
  final Widget child;
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomInset = SdContentPaddingV4.detailBottom(context);
    final double keyboardInset = SdContentPaddingV4.keyboardInset(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        height: heightFactor == null
            ? null
            : MediaQuery.sizeOf(context).height * heightFactor!,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            SdContentPaddingV4.horizontal,
            SdSpacingConstant.h12,
            SdSpacingConstant.w8,
            bottomInset + keyboardInset,
          ),
          child: Column(
            mainAxisSize: heightFactor == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text(title, style: textTheme.titleLarge)),
                  IconButton(
                    tooltip: closeTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const SdIconV4(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: SdSpacingConstant.h12),
              if (heightFactor == null) child else Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showSdBottomSheetV4<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: colorScheme.surface,
    barrierColor: colorScheme.scrim.withValues(alpha: 0.32),
    shape: RoundedRectangleBorder(borderRadius: SdRadiusV4.modalTop),
  );
}
