import 'package:flutter/material.dart';

import '../sd_content_padding_v2/sd_content_padding_v2.dart';
import '../sd_context_v2/sd_context_v2.dart';
import '../sd_spacing_v2/sd_spacing_v2.dart';

/// The app's pull-to-refresh wrapper — one themed [RefreshIndicator] so every
/// tab refreshes the same way. Wrap a scrollable [child] (use
/// [AlwaysScrollableScrollPhysics] on it so short content still pulls); for a
/// non-scrollable state (an empty state), wrap it in [SdScrollFillV2] first.
///
/// The spinner drops in below the translucent app bar via [edgeOffset], so it
/// isn't hidden behind the glass chrome.
class SdRefreshIndicatorV2 extends StatelessWidget {
  const SdRefreshIndicatorV2({
    required this.onRefresh,
    required this.child,
    this.edgeOffset,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  /// Where the spinner drops in from. Defaults to the app-bar height plus a
  /// margin so the spinner clears the translucent chrome (the RefreshIndicator
  /// lives in the body, which is painted BEHIND the glass app bar — without
  /// the offset the spinner emerges under the bar and looks clipped). Pass 0
  /// when the wrapped scrollable already starts below other content.
  final double? edgeOffset;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: context.colorScheme.primary,
      backgroundColor: context.sdTheme.surfaceElevated,
      edgeOffset:
          edgeOffset ??
          SdContentPaddingV2.appBarInset(context) + SdSpacingV2.h20,
      child: child,
    );
  }

  /// Runs [invalidate] (a tab's `ref.invalidate(...)` calls so its providers
  /// reload), then holds briefly so the refresh spinner reads as deliberate
  /// even when the (local-first) data reloads instantly. Use as a tab's
  /// `onRefresh`.
  static Future<void> run(void Function() invalidate) async {
    invalidate();
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
}

/// Makes a non-scrollable widget (e.g. an [SdEmptyStateV2]) fill the viewport and
/// still be pull-to-refreshable. Uses [SliverFillRemaining] rather than a
/// `LayoutBuilder` on purpose: a LayoutBuilder builds its child DURING layout,
/// and a Riverpod consumer resuming inside that layout-phase build can trigger
/// "setState() called during build". A sliver avoids that entirely.
class SdScrollFillV2 extends StatelessWidget {
  const SdScrollFillV2({required this.child, this.topInset = 0, super.key});

  final Widget child;

  /// Space above the child so it clears the translucent app bar.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: topInset),
          sliver: SliverFillRemaining(hasScrollBody: false, child: child),
        ),
      ],
    );
  }
}
