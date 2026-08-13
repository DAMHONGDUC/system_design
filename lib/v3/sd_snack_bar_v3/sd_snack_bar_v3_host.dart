part of 'sd_snack_bar_v3.dart';

/// Positions the card, animates it in, and takes it away again.
///
/// The animation is a short fade and a small slide — calm, per the package's
/// behaviour rules. Nothing flashes or pulses.
class _SdSnackBarHostV3 extends StatefulWidget {
  const _SdSnackBarHostV3({
    required this.message,
    required this.kind,
    required this.placement,
    required this.onDismissed,
  });

  final String message;
  final SdSnackBarKindV3 kind;
  final SdSnackBarPlacementV3 placement;
  final VoidCallback onDismissed;

  @override
  State<_SdSnackBarHostV3> createState() => _SdSnackBarHostV3State();
}

class _SdSnackBarHostV3State extends State<_SdSnackBarHostV3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SdMotionV3.normal,
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(SdMotionV3.snackBar, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Reverses the entry animation, then removes the entry.
  ///
  /// Guarded on `mounted`: the entry can be removed by a newer message while
  /// this one is still counting down, and driving a disposed controller is
  /// what turns a snackbar into a crash.
  Future<void> _dismiss() async {
    if (!mounted) return;

    await _controller.reverse();

    if (!mounted) return;

    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final bool fromBottom = widget.placement == SdSnackBarPlacementV3.bottom;

    return Positioned(
      left: SdContentPaddingV3.horizontal,
      right: SdContentPaddingV3.horizontal,
      // Both insets come off the view through SdContentPaddingV3. An ambient
      // read here returns 0 for the home indicator, because this host sits
      // inside a Scaffold body that already had it removed.
      top: fromBottom
          ? null
          : SdContentPaddingV3.statusBarInset(context) + SdSpacingConstant.h12,
      bottom: fromBottom ? SdContentPaddingV3.detailBottom(context) : null,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: SdMotionV3.standard,
          reverseCurve: SdMotionV3.exit,
        ),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: Offset(0, fromBottom ? 0.2 : -0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: SdMotionV3.standard,
                ),
              ),
          // The overlay has no Material ancestor of its own, so the card has
          // to bring one or every Text in it renders with debug underlines.
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: _dismiss,
              child: SdSnackBarCardV3(
                message: widget.message,
                kind: widget.kind,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
