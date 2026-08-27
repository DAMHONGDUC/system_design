import 'package:flutter/widgets.dart';

import '../sd_context_v3/sd_context_v3.dart';

/// The shadows v3 casts, named by what wears them.
///
/// **Every one resolves through [SdThemeV3.shadow], so a dark palette that
/// sets it transparent gets no shadows at all** — which is correct rather
/// than a degradation. A shadow works by darkening the surface behind it; on
/// a near-black page there is nothing to darken, and a shadow tuned for light
/// reads as grime. Dark leans on the border and the surface step instead.
///
/// Kept deliberately shallow. Reseller Studio is a working tool with a lot of
/// stacked surfaces, and the moment shadows get deep enough to notice
/// individually, a screen with six cards looks like it is hovering apart.
final class SdElevationV3 {
  /// A card resting on the page. The default, and the only one most surfaces
  /// need.
  static List<BoxShadow> card(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.sdTheme3.shadow,
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: context.sdTheme3.shadow,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Something the user has picked up or that floats over content — a
  /// selected row, a hero card, a FAB.
  static List<BoxShadow> raised(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.sdTheme3.shadow,
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: context.sdTheme3.shadow,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  /// Sheets and dialogs, which must read as detached from everything.
  static List<BoxShadow> modal(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: context.sdTheme3.shadow,
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  /// No shadow. A named value rather than `const <BoxShadow>[]` at call
  /// sites, so "flat on purpose" and "nobody got round to it" look different
  /// in the code.
  static const List<BoxShadow> none = <BoxShadow>[];
}
