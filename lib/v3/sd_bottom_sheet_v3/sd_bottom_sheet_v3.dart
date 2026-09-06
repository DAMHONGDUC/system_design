import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_app_bar_action_button_v3/sd_app_bar_action_button_v3.dart';
import '../sd_content_padding_v3/sd_content_padding_v3.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_keyboard_dismiss_v3/sd_keyboard_dismiss_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// How a sheet may be left — a prop, because it changes the chrome and the
/// route together.
enum SdBottomSheetExitV3 {
  /// The default. A close button, a grab handle, a barrier tap and a back
  /// gesture all dismiss it.
  close,

  /// Nothing dismisses it: no close button, no handle, no barrier tap, no
  /// back. For a sheet that **is** the app's state rather than something
  /// shown over it — a build too old to run.
  ///
  /// **It is the one exception to "every sheet carries a close icon"**
  /// (`docs/rules/DESIGN_SYSTEM.md`). That rule exists so a seller always has
  /// one exit nothing has to teach; here there deliberately is no exit, and a
  /// close button that reopened itself a frame later would be worse than none.
  blocked,
}

/// Carries the presenter's [SdBottomSheetExitV3] down to the sheet.
///
/// **One owner for the value.** The route's `isDismissible` and the chrome's
/// close button are two halves of one decision, and passing the flag to both
/// the presenter and the widget is how they end up disagreeing — a sheet with
/// no close button that the barrier still dismisses.
class _SdBottomSheetExitScopeV3 extends InheritedWidget {
  const _SdBottomSheetExitScopeV3({required this.exit, required super.child});

  final SdBottomSheetExitV3 exit;

  static SdBottomSheetExitV3 of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_SdBottomSheetExitScopeV3>()
          ?.exit ??
      SdBottomSheetExitV3.close;

  @override
  bool updateShouldNotify(_SdBottomSheetExitScopeV3 oldWidget) =>
      oldWidget.exit != exit;
}

/// The chrome every bottom sheet in the app wears: a grab handle, a title,
/// and the caller's content under it.
///
/// The handle is decorative and excluded from semantics — a screen reader
/// announcing "handle" before the sheet's title is noise.
///
/// **[heightFactor] is what makes it a document rather than a menu.** See
/// that field.
///
/// **[heightFactor] is what makes it a document rather than a menu.** See
/// that field.
///
/// **It wraps its content in [SdKeyboardDismissV3] itself**, and needs to: a
/// sheet is a route of its own, so it is not inside the scaffold underneath it
/// and inherits nothing from that one — and a sheet is where most of this
/// app's typing happens.
class SdBottomSheetV3 extends StatelessWidget {
  const SdBottomSheetV3({
    required this.title,
    required this.closeTooltip,
    required this.child,
    this.heightFactor,
    super.key,
  });

  final String title;

  /// Already-localized tooltip and semantics label for the close button.
  ///
  /// **Null only for a sheet presented as [SdBottomSheetExitV3.blocked]**,
  /// which draws no close button — asserted in [build], because the exit comes
  /// from the presenter and is not known at construction. Every other sheet
  /// still cannot ship without one.
  final String? closeTooltip;

  final Widget child;

  /// How much of the screen the sheet takes, as a fraction.
  ///
  /// **Null sizes the sheet to its content, and that is the default.** A menu
  /// taller than its rows is a sheet with dead space under the thumb that has
  /// to reach past it. A sheet that is *read* rather than chosen from passes
  /// this instead, so its scroll starts at a predictable place and enough of
  /// the page behind stays visible to say the sheet is dismissable.
  ///
  /// A fraction rather than a number of points on purpose: a height typed in
  /// points is a height that is wrong on the next device. The [child] is
  /// stretched to fill whatever is left under the title, so it brings its own
  /// scroll view.
  final double? heightFactor;

  /// The grab handle's drawn size. Intrinsic to this widget, so it lives on
  /// it rather than on a spacing class.
  static double get handleWidth => SdSpacingConstant.w40;
  static double get handleHeight => SdSpacingConstant.h4;

  @override
  Widget build(BuildContext context) {
    final SdBottomSheetExitV3 exit = _SdBottomSheetExitScopeV3.of(context);
    final bool blocked = exit == SdBottomSheetExitV3.blocked;

    assert(
      blocked || closeTooltip != null,
      'A dismissable sheet needs a close tooltip.',
    );

    return PopScope(canPop: !blocked, child: _chrome(context, blocked));
  }

  Widget _chrome(BuildContext context, bool blocked) => SdKeyboardDismissV3(
    child: SizedBox(
      height: heightFactor == null
          ? null
          : MediaQuery.sizeOf(context).height * heightFactor!,
      child: Container(
        decoration: BoxDecoration(
          color: context.sdTheme3.surfaceModal,
          borderRadius: SdRadiusV3.modalTop,
          border: Border.all(color: context.sdTheme3.border),
        ),
        padding: EdgeInsets.only(
          left: SdContentPaddingV3.horizontal,
          right: SdContentPaddingV3.horizontal,
          top: SdSpacingConstant.h12,
          // - clears the home indicator, because a sheet's last row is the one a
          //   thumb reaches for
          // - lifts over the keyboard, so no caller wraps this in its own Padding
          bottom:
              SdContentPaddingV3.detailBottom(context) +
              SdContentPaddingV3.keyboardInset(context),
        ),
        child: Column(
          // Min sizes the sheet to its rows; max is what lets the Expanded
          // below have space to take.
          mainAxisSize: heightFactor == null
              ? MainAxisSize.min
              : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // The handle says "drag me", so a sheet nothing dismisses does not
            // draw one.
            if (!blocked) ...<Widget>[
              Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: handleWidth,
                    height: handleHeight,
                    decoration: BoxDecoration(
                      color: context.sdTheme3.border,
                      borderRadius: SdRadiusV3.fullAll,
                    ),
                  ),
                ),
              ),
              SizedBox(height: SdSpacingConstant.h16),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme3.titleMedium!.semiBold3.copyWith(
                      color: context.sdTheme3.textPrimary,
                    ),
                  ),
                ),
                if (!blocked)
                  SdAppBarActionButtonV3(
                    icon: Symbols.close_rounded,
                    tooltip: closeTooltip!,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
            SizedBox(height: SdSpacingConstant.h16),
            // Expanded only when a height was asked for: a min-sized Column has
            // no spare space to give, and Expanded inside one throws.
            if (heightFactor == null) child else Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

/// Show a sheet over everything, including the floating tab bar.
///
/// A sanctioned top-level presenter (`WIDGET_RULES.md` §5).
/// **`useRootNavigator: true` is not optional here** — a sheet pushed on a
/// shell branch's own navigator slides *under* the floating glass tab bar,
/// which reads as a rendering bug and puts the sheet's first action beneath
/// it.
///
/// **[exit] is set here and nowhere else.** It reaches the sheet through an
/// inherited scope, so the route's dismissability and the chrome's close
/// button cannot disagree — see [_SdBottomSheetExitScopeV3].
Future<T?> showSdBottomSheetV3<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SdBottomSheetExitV3 exit = SdBottomSheetExitV3.close,
}) {
  final bool dismissable = exit == SdBottomSheetExitV3.close;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: dismissable,
    enableDrag: dismissable,
    backgroundColor: Colors.transparent,
    barrierColor: context.sdTheme3.barrier,
    // `Builder` so the sheet is built *below* the scope: passing
    // `builder(context)` directly would construct it with the context above,
    // where the scope is not visible.
    builder: (BuildContext sheetContext) => _SdBottomSheetExitScopeV3(
      exit: exit,
      child: Builder(builder: builder),
    ),
  );
}
