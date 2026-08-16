import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_icon_v3/sd_icon_v3.dart';
import '../sd_radius_v3/sd_radius_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The app bar every v3 screen wears.
///
/// Opaque, flat, and one hairline off the content below it. v2's frosted
/// glass is deliberately not carried over: it costs a shader pass on every
/// scroll frame, and Inventory scrolls a list that can run to thousands of
/// rows on the cheapest Android a reseller owns.
///
/// **It is the system's height, and its title is set smaller.**
/// [toolbarHeight] is 56 — `kToolbarHeight`, expressed in this package's
/// scale — so the bar matches the platform chrome a seller sees in every
/// other app on their phone. It was 48 for a while, on the reasoning that
/// eight points of chrome on every route is a row of inventory; the bar
/// reading as *this app's* bar rather than the system's was the higher cost,
/// so it follows the system now.
///
/// The title stays `titleMedium` rather than the 22sp display face. A screen
/// title is a label, not a headline, and the screen's own content is what
/// should be loud — that half of the rule did not change.
///
/// [title] is a `String` because a screen title is always a string —
/// a widget slot here is how app bars grow bespoke layouts that stop matching
/// each other.
class SdAppBarV3 extends StatelessWidget implements PreferredSizeWidget {
  const SdAppBarV3({
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.onTitleTap,
    super.key,
  });

  /// A second line under the title — the workspace name on Home, the item
  /// SKU on a detail screen. Optional, and the bar grows to fit it.
  final String? subtitle;

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// A pinned strip under the bar — a filter chip row, a tab set.
  final PreferredSizeWidget? bottom;

  /// Makes the title itself the control, with a chevron to say so.
  ///
  /// For a bar whose title *names the thing being shown* and where that thing
  /// can be changed — the workspace on Home. Null leaves the title plain
  /// text, which is what almost every screen wants: a title that looks
  /// tappable and is not is worse than one that never suggested it.
  final VoidCallback? onTitleTap;

  /// The height of the title row, and the number anything drawing its own
  /// bar-like row measures against — `SdSearchHeaderV3` is the same height so
  /// the two read as one piece of chrome across screens.
  ///
  /// `kToolbarHeight`'s 56, taken through the spacing scale rather than as the
  /// raw constant: everything the bar contains is scaled, and a raw 56 next to
  /// a scaled child is how the row and the control inside it drift apart on a
  /// device whose aspect differs from the design canvas.
  static double get toolbarHeight => SdSpacingConstant.h56;

  /// What a [subtitle] adds. The second line is `bodySmall`, so it costs less
  /// than a full row.
  static double get subtitleHeight => SdSpacingConstant.h16;

  @override
  Size get preferredSize => Size.fromHeight(
    toolbarHeight +
        (subtitle == null ? 0 : subtitleHeight) +
        (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: context.sdTheme3.background,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: false,
    toolbarHeight: toolbarHeight + (subtitle == null ? 0 : subtitleHeight),
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    actions: actions,
    bottom: bottom,
    titleSpacing: SdSpacingConstant.w16,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (onTitleTap == null)
          Text(
            title,
            style: context.textTheme3.titleMedium!.semiBold3.copyWith(
              color: context.sdTheme3.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        else
          _SdAppBarTitleButtonV3(title: title, onTap: onTitleTap!),
        if (subtitle != null)
          Text(
            subtitle!,
            style: context.textTheme3.bodySmall!.muted3(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    ),
  );
}

/// A title that opens something. Split out so the plain case stays a bare
/// [Text] with no gesture detector wrapped around it.
class _SdAppBarTitleButtonV3 extends StatelessWidget {
  const _SdAppBarTitleButtonV3({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: SdRadiusV3.chipAll,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SdSpacingConstant.w4,
        vertical: SdSpacingConstant.h2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              title,
              style: context.textTheme3.titleMedium!.semiBold3.copyWith(
                color: context.sdTheme3.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: SdSpacingConstant.w4),
          SdIconV3(
            Icons.keyboard_arrow_down_rounded,
            size: SdIconV3.smallSize,
            color: context.sdTheme3.textSecondary,
          ),
        ],
      ),
    ),
  );
}
