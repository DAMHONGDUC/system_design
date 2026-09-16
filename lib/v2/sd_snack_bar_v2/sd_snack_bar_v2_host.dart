part of 'sd_snack_bar_v2.dart';

/// Places the card against one edge, fades and slides it in from that edge,
/// then takes it away again — when [duration] runs out, or when the user
/// swipes it back towards the edge it came from.
class _SdSnackBarHostV2 extends StatefulWidget {
  const _SdSnackBarHostV2({
    required this.message,
    required this.kind,
    required this.placement,
    required this.floatingBarInset,
    required this.duration,
    required this.onDismissed,
    required this.onDisposed,
  });

  final String message;
  final SdSnackBarKindV2 kind;
  final SdSnackBarPlacementV2 placement;

  /// What a floating bottom bar occupies where this was raised, 0 without one.
  final double floatingBarInset;

  final Duration duration;
  final VoidCallback onDismissed;
  final VoidCallback onDisposed;

  /// Calm, and inside hard rule 3's ceiling either way.
  static const Duration transition = Duration(milliseconds: 220);

  /// Pulled this far towards its edge, letting go takes the card away. Short
  /// on purpose — the gesture is a flick at a card that is leaving anyway, not
  /// a drag with a target.
  static double get dismissDistance => SdSpacingConstant.h24;

  /// A flick faster than this dismisses however short it was, in logical
  /// pixels per second. Below it, only [dismissDistance] decides.
  static const double dismissVelocity = 320;

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

  /// How far the finger has taken the card from its resting place, in logical
  /// pixels, signed the way the screen is: negative up, positive down.
  double _drag = 0;

  /// The finger is down — the card tracks it frame for frame, so the spring
  /// back is animated and the drag itself never is.
  bool _dragging = false;

  bool get _atTop => widget.placement == SdSnackBarPlacementV2.top;

  /// The way out: up for a card resting at the top, down for one at the bottom.
  double get _dismissSign => _atTop ? -1 : 1;

  @override
  void initState() {
    super.initState();

    _controller.forward();
    _restartTimer();
  }

  @override
  void dispose() {
    // Cancel the timer: it can outlive a route pop or torn-down test if left uncancelled.
    _timer?.cancel();
    _curve.dispose();
    _controller.dispose();
    widget.onDisposed();

    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _leave);
  }

  Future<void> _leave() async {
    _timer?.cancel();

    if (!mounted) return;

    await _controller.reverse();

    if (mounted) widget.onDismissed();
  }

  /// A card being read is a card being kept: the countdown stops for as long as
  /// the finger is on it, or a drag that changes its mind would be cut short by
  /// a timer that ran while the user was holding on.
  void _dragStart(DragStartDetails _) {
    _timer?.cancel();
    setState(() => _dragging = true);
  }

  void _dragUpdate(DragUpdateDetails details) {
    // Only the way out moves. The other direction is clamped rather than
    // rubber-banded: a card at the top edge that can be pulled down is a card
    // the user has to put back, for a gesture that does nothing either way.
    final double next = _drag + details.delta.dy;

    setState(() => _drag = _atTop ? math.min(next, 0) : math.max(next, 0));
  }

  void _dragEnd(DragEndDetails details) {
    setState(() => _dragging = false);

    final double travel = _drag * _dismissSign;
    final double speed = details.velocity.pixelsPerSecond.dy * _dismissSign;

    // Far enough, or fast enough: a flick that has barely moved is still an
    // answer, and waiting for the distance would ignore it.
    if (travel >= _SdSnackBarHostV2.dismissDistance ||
        speed >= _SdSnackBarHostV2.dismissVelocity) {
      unawaited(_leave());
      return;
    }

    // Kept: the card springs back and gets its full time again, because the
    // seconds it spent under a finger were not seconds spent being read.
    setState(() => _drag = 0);
    _restartTimer();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
    final double offset = SdSpacingConstant.h16;
    // Rests on whichever is lower: the home indicator, or the nav pill the
    // message would otherwise land on top of.
    final double floor = math.max(safe.bottom, widget.floatingBarInset);

    return Positioned(
      left: SdSpacingConstant.w16,
      right: SdSpacingConstant.w16,
      top: _atTop ? safe.top + offset : null,
      bottom: _atTop ? null : floor + offset,
      child: FadeTransition(
        opacity: _curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, _atTop ? -0.4 : 0.4),
            end: Offset.zero,
          ).animate(_curve),
          // The overlay has no Material ancestor; text without one renders Flutter's yellow underlined fallback.
          child: Material(
            type: MaterialType.transparency,
            // - the card takes pointers so it can be swiped away, which costs
            //   the taps that land on it while it is up: it floats above every
            //   route, so a tap here is a tap a sheet's button underneath does
            //   not get
            // - the trade is deliberate and it is why the card is small, sits
            //   in a margin, and leaves on its own in seconds
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: _dragStart,
              onVerticalDragUpdate: _dragUpdate,
              onVerticalDragEnd: _dragEnd,
              // Zero duration while the finger is down: the card IS the
              // finger's position, and easing towards it would put the card a
              // few frames behind the thumb. Let go and the same builder
              // animates whatever distance is left, in or out.
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: _drag),
                duration: _dragging
                    ? Duration.zero
                    : _SdSnackBarHostV2.transition,
                curve: Curves.easeOutCubic,
                builder: (BuildContext _, double dy, Widget? card) =>
                    Transform.translate(offset: Offset(0, dy), child: card),
                child: SdSnackBarCardV2(
                  message: widget.message,
                  kind: widget.kind,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
