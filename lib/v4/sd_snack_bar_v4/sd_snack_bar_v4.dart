import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';

enum SdSnackBarKindV4 { success, error, info }

/// One transient message at a time, raised into the root overlay so it clears
/// sheets and the floating navigation bar.
///
/// Pass a finished, localized string — this package holds no strings.
final class SdSnackBarV4 {
  static const Duration _visibleFor = Duration(seconds: 4);

  static OverlayEntry? _current;
  static Timer? _timer;

  static void showSuccess(BuildContext context, String message) =>
      _show(context, message, SdSnackBarKindV4.success);

  static void showError(BuildContext context, String message) =>
      _show(context, message, SdSnackBarKindV4.error);

  static void showInfo(BuildContext context, String message) =>
      _show(context, message, SdSnackBarKindV4.info);

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }

  static void _show(
    BuildContext context,
    String message,
    SdSnackBarKindV4 kind,
  ) {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss();
    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) =>
          _SdSnackBarHostV4(message: message, kind: kind),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(_visibleFor, dismiss);
  }
}

class _SdSnackBarHostV4 extends StatelessWidget {
  const _SdSnackBarHostV4({required this.message, required this.kind});

  final String message;
  final SdSnackBarKindV4 kind;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (Color background, Color foreground, IconData icon) = switch (kind) {
      SdSnackBarKindV4.success => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Icons.check_circle_rounded,
      ),
      SdSnackBarKindV4.error => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error_outline_rounded,
      ),
      SdSnackBarKindV4.info => (
        colors.surfaceContainerLow,
        colors.onSurface,
        Icons.info_outline_rounded,
      ),
    };

    return Positioned(
      top: MediaQuery.viewPaddingOf(context).top + SdSpacingConstant.h12,
      left: SdSpacingConstant.w16,
      right: SdSpacingConstant.w16,
      child: SafeArea(
        bottom: false,
        child: Material(
          color: Colors.transparent,
          child: Semantics(
            liveRegion: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(SdSpacingConstant.r16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SdSpacingConstant.w16,
                  vertical: SdSpacingConstant.h12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      icon,
                      color: foreground,
                      size: SdSpacingConstant.r20,
                    ),
                    SizedBox(width: SdSpacingConstant.w12),
                    Expanded(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
