import 'package:flutter/animation.dart';

/// Every duration and curve v3 animates on. No widget writes a
/// `Duration(milliseconds: …)` or names a [Curve] inline.
///
/// Two durations and two curves cover almost everything, which is the point:
/// a system where each animation picks its own timing reads as a pile of
/// separate animations. Reach past [fast] and [normal] only when the motion
/// genuinely covers more distance.
///
/// Reseller Studio is a working tool used in a stockroom with one hand — motion
/// exists to explain where something came from, never to be admired. Nothing
/// here loops, bounces or overshoots, and nothing crosses [slow].
final class SdMotionV3 {
  /// State flips on a control already under the user's thumb: a checkbox, a
  /// chip selecting, a press tint. Long enough to be seen, short enough that
  /// bulk-tapping 40 items never feels like waiting.
  static const Duration fast = Duration(milliseconds: 150);

  /// The default. Anything appearing, dismissing or moving inside a screen.
  static const Duration normal = Duration(milliseconds: 250);

  /// Sheets and dialogs — a bigger surface travelling further.
  static const Duration slow = Duration(milliseconds: 350);

  /// How long a snack bar stays up. Not an animation, but it belongs to the
  /// same budget: shorter and a Vietnamese string outruns it, longer and it
  /// sits over the FAB the user is reaching for.
  static const Duration snackBar = Duration(seconds: 4);

  /// Debounce before a search query is sent. Every keystroke in global
  /// search would otherwise be a Firestore read.
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// The default curve — decelerating, no overshoot.
  static const Curve standard = Curves.easeOutCubic;

  /// Something leaving. Accelerating out is what makes a dismissal feel
  /// answered rather than reluctant.
  static const Curve exit = Curves.easeInCubic;

  /// Something both entering and leaving in one animation (a cross-fade, a
  /// size change).
  static const Curve emphasized = Curves.easeInOutCubic;
}
