/// System Design — the v3 widget set, built for Seller OS.
///
/// Consumers import `package:system_design/index.dart`, not this file: the
/// package's entry point re-exports this alongside `core/` and `v2/`. This
/// list exists so a widget generation stays one self-contained folder.
///
/// **v3 does not import v2, and never will.** The two generations ship side
/// by side so an app can migrate widget by widget; a v3 widget that reached
/// into `v2/` would make that impossible and would drag v2's dark-only,
/// frosted-glass assumptions into a design system that is neither.
///
/// Every widget lives in its own folder under `v3/` and is exported here.
/// Adding a widget means adding one folder and one line below — nothing else
/// in the package changes. See `WIDGET_RULES.md`, which is the authority.
library;

export 'sd_app_bar_v3/sd_app_bar_v3.dart';
export 'sd_badge_v3/sd_badge_v3.dart';
export 'sd_button_v3/sd_button_v3.dart';
export 'sd_card_v3/sd_card_v3.dart';
export 'sd_content_padding_v3/sd_content_padding_v3.dart';
export 'sd_context_v3/sd_context_v3.dart';
export 'sd_elevation_v3/sd_elevation_v3.dart';
export 'sd_empty_state_v3/sd_empty_state_v3.dart';
export 'sd_fab_v3/sd_fab_v3.dart';
export 'sd_filter_chip_v3/sd_filter_chip_v3.dart';
export 'sd_glass_nav_bar_v3/sd_glass_nav_bar_v3.dart';
export 'sd_hero_stat_v3/sd_hero_stat_v3.dart';
export 'sd_icon_tile_v3/sd_icon_tile_v3.dart';
export 'sd_icon_v3/sd_icon_v3.dart';
export 'sd_loading_v3/sd_loading_v3.dart';
export 'sd_motion_v3/sd_motion_v3.dart';
export 'sd_radius_v3/sd_radius_v3.dart';
export 'sd_scaffold_v3/sd_scaffold_v3.dart';
export 'sd_search_field_v3/sd_search_field_v3.dart';
export 'sd_search_header_v3/sd_search_header_v3.dart';
export 'sd_section_header_v3/sd_section_header_v3.dart';
export 'sd_stat_tile_v3/sd_stat_tile_v3.dart';
export 'sd_text_field_v3/sd_text_field_v3.dart';
export 'sd_text_style_v3/sd_text_style_v3.dart';
export 'sd_theme_v3/sd_theme_v3.dart';
