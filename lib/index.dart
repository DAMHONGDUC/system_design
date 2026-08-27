/// System Design — the one import for everything in this package.
///
/// ```dart
/// import 'package:system_design/index.dart';
/// ```
///
/// `core/` holds what does not belong to a widget generation: raw dimensions
/// that any version of the system measures in. `v2/` and `v3/` are the widget
/// generations, and each owns everything about its own look.
///
/// **Both ship at once, and neither imports the other.** BaroEase renders on
/// v2; Reseller Studio renders on v3. An app that wanted to move between them could
/// do it widget by widget, because every name is suffixed with its
/// generation — `SdButtonV2` and `SdButtonV3` can sit in one file, and the
/// two `BuildContext` extensions do not collide (`context.sdTheme` is v2's,
/// `context.sdTheme3` is v3's).
///
/// A widget added to one generation is never "ported" to the other by import.
/// v2 is frozen for v3 work: it is what a shipped app is rendering, and a
/// change made to suit a different product is a change made to an app nobody
/// asked to redesign.
library;

export 'common.dart';
export 'core/sd_spacing_constant.dart';
export 'utils/text_ext.dart';
export 'v2/index.dart';
export 'v3/index.dart';
