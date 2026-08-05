part of 'sd_snack_bar_v2.dart';

/// Places the card against one edge, fades and slides it in from that edge,
/// then takes it away again — either when [duration] runs out or when the
/// user swipes it sideways.
class _SdSnackBarHostV2 extends StatefulWidget {
  const _SdSnackBarHostV2({
    required this.message,
    required this.kind,
    required this.placement,
    required this.duration,
    required this.onDismissed,
    required this.onDisposed,
  });

  final String message;
  final SdSnackBarKindV2 kind;
  final SdSnackBarPlacementV2 placement;
  final Duration duration;
  final VoidCallback onDismissed;
  final VoidCallback onDisposed;

  /// Calm, and inside hard rule 3's ceiling either way.
  static const Duration transition = Duration(milliseconds: 220);

  @override
  State<_SdSnackBarHostV2> createState() => _SdSnackBarHostV2State();
}

class _SdSnackBarHostV2State extends State<_SdSnackBarHostV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _SdSnackBarHostV2.transition,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller.forward();
    _timer = Timer(widget.duration, _leave);
  }

  @override
  void dispose() {
    // The overlay entry can go before the timer fires — a route pop, or a test
    // ending. An uncancelled timer would outlive the tree it calls back into.
    _timer?.cancel();
    _curve.dispose();
    _controller.dispose();
    widget.onDisposed();

    super.dispose();
  }

  Future<void> _leave() async {
    _timer?.cancel();

    if (!mounted) return;

    await _controller.reverse();

    if (mounted) widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
    final bool atTop = widget.placement == SdSnackBarPlacementV2.top;
    final double offset = SdSpacingConstant.h16;

    return Positioned(
      left: SdSpacingConstant.w16,
      right: SdSpacingConstant.w16,
      top: atTop ? safe.top + offset : null,
      bottom: atTop ? null : safe.bottom + offset,
      child: FadeTransition(
        opacity: _curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, atTop ? -0.4 : 0.4),
            end: Offset.zero,
          ).animate(_curve),
          // Floating above every route means it would also take taps meant
          // for the route — a card over a sheet's buttons swallows them for
          // its whole duration. It leaves on its own; a message is never
          // worth a tap that does not land. That costs swipe-to-dismiss, and
          // that is the cheaper half of the trade.
          child: IgnorePointer(
            // The overlay has no Material ancestor, and text without one
            // renders Flutter's yellow underlined fallback.
            child: Material(
              type: MaterialType.transparency,
              child: SdSnackBarCardV2(
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
