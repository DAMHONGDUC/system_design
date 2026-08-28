import 'package:flutter/material.dart';

/// Drops focus — and with it the keyboard — when the user taps anything that
/// is not a control.
///
/// **Wrapped once by `SdScaffoldV3` and once by `SdBottomSheetV3`, and nowhere
/// else.** Those two are every surface in the app a field can sit on, so no
/// screen writes this for itself and no form ships without it. A sheet needs
/// its own because it is a route of its own: it is not inside the scaffold
/// underneath it and inherits nothing from that one.
///
/// Two details make it safe to wrap everything:
/// - the hit test is translucent, so this is only reached when nothing nearer
///   claimed the tap — a button, a row, the field itself;
/// - a scroll drag defeats a tap, so scrolling past a focused field is
///   unaffected.
class SdKeyboardDismissV3 extends StatelessWidget {
  const SdKeyboardDismissV3({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    behavior: HitTestBehavior.translucent,
    child: child,
  );
}
