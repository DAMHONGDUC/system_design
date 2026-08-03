/// System Design — the one import for everything in this package.
///
/// ```dart
/// import 'package:system_design/index.dart';
/// ```
///
/// `core/` holds what does not belong to a widget generation: raw dimensions
/// that any version of the system measures in. `v2/` is the current widget
/// set, and owns everything that has a look. A future generation gets a
/// `v3/` beside it, exported from here too, so an app can migrate widget by
/// widget instead of all at once.
library;

export 'core/sd_spacing_constant.dart';
export 'utils/text_ext.dart';
export 'v2/index.dart';
