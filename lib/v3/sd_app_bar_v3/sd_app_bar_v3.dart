import 'package:flutter/material.dart';

import '../../core/sd_spacing_constant.dart';
import '../sd_context_v3/sd_context_v3.dart';
import '../sd_text_style_v3/sd_text_style_v3.dart';

/// The app bar every v3 screen wears.
///
/// Opaque, flat, and one hairline off the content below it. v2's frosted
/// glass is deliberately not carried over: it costs a shader pass on every
/// scroll frame, and Inventory scrolls a list that can run to thousands of
/// rows on the cheapest Android a reseller owns.
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

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight +
        (subtitle == null ? 0 : SdSpacingConstant.h16) +
        (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: context.sdTheme3.background,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: false,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    actions: actions,
    bottom: bottom,
    titleSpacing: SdSpacingConstant.w16,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          style: context.textTheme3.titleLarge!.semiBold3.copyWith(
            color: context.sdTheme3.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
