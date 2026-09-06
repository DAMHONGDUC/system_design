import 'package:flutter/widgets.dart';

part 'sd_dev_wrapper_tag.dart';

/// Stamps a build tag down the right edge of everything the app draws, hung
/// from the top-right corner.
///
/// **It wraps `MaterialApp`, it never sits inside one**, and that is the whole
/// reason it looks the way it does: above the app there is no theme, no
/// `Directionality`, no `MediaQuery` and no `Material`, so it brings its own
/// text direction and hardcodes its two colours rather than reading tokens
/// that are not registered yet. That also makes it immune to the thing it
/// exists to catch — a tag drawn from the app's palette disappears the moment
/// the app's palette is what is broken.
///
/// It lives in `core/` rather than in a generation because it carries no
/// product look: every app of ours wants the same strip, drawn identically,
/// so that a screenshot in a bug report says which build it came from.
///
/// The host decides when it shows — pass [visible] from the flavour, never
/// from `kDebugMode`: a TestFlight build of the dev flavour is a release
/// binary and is exactly the one nobody can otherwise identify.
///
/// **It draws a tag and nothing else.** It used to carry the fresh-install
/// check too; that is `SdFreshInstall`, the host awaits it before `runApp`,
/// and it never belonged behind a widget whose job is decoration.
class SdDevWrapper extends StatelessWidget {
  const SdDevWrapper({
    required this.child,
    required this.envName,
    this.buildName = '',
    this.buildNumber = '',
    this.visible = true,
    super.key,
  });

  /// The app, normally `MaterialApp` itself.
  final Widget child;

  /// Which build this is — `dev`, `staging`. Drawn upper-cased.
  final String envName;

  /// The marketing version, the `1.0.0` of `1.0.0+8`. Empty is left out.
  final String buildName;

  /// The build number, the `8` of `1.0.0+8`. Empty is left out.
  final String buildNumber;

  /// Whether to draw the tag at all. False leaves the tree with no extra
  /// painting node.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          child,
          Positioned(
            // No MediaQuery above MaterialApp, so the status bar inset is read
            // off the view itself — otherwise the slab sits on the clock.
            top: MediaQueryData.fromView(View.of(context)).padding.top,
            right: 0,
            child: IgnorePointer(child: _SdDevWrapperTag(label: _label)),
          ),
        ],
      ),
    );
  }

  /// `DEV · 1.0.0 (8)`, dropping whatever the host could not tell us — a
  /// version the platform channel has not answered for yet is left out rather
  /// than drawn as an empty bracket.
  String get _label {
    final StringBuffer buffer = StringBuffer(envName.toUpperCase());

    if (buildName.isNotEmpty) {
      buffer.write('${_SdDevWrapperConstant.separator}$buildName');
    }
    if (buildNumber.isNotEmpty) {
      buffer.write(buildName.isEmpty ? _SdDevWrapperConstant.separator : ' ');
      buffer.write('($buildNumber)');
    }

    return buffer.toString();
  }
}
