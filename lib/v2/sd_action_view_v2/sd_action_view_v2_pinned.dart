part of 'sd_action_view_v2.dart';

/// Only the content scrolls; the actions hold the bottom edge.
///
/// The actions sit BELOW the scroll view rather than over it, so content can
/// never pass behind them — which is why the footer needs no surface of its
/// own and no blur. What separates the two is
/// [SdContentPaddingV2.pinnedActionsGap].
class _Pinned extends StatelessWidget {
  const _Pinned({
    required this.content,
    required this.actions,
    required this.contentInsets,
    required this.actionInsets,
  });

  final Widget content;
  final Widget actions;
  final EdgeInsetsGeometry contentInsets;
  final EdgeInsetsGeometry actionInsets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // The top inset goes INSIDE the scroll view, so content still passes
        // behind the frosted app bar instead of starting below it.
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: contentInsets.add(
                EdgeInsets.only(top: SdContentPaddingV2.top(context)),
              ),
              child: content,
            ),
          ),
        ),
        Padding(
          padding: actionInsets.add(
            EdgeInsets.only(
              top: SdContentPaddingV2.pinnedActionsGap,
              bottom: SdContentPaddingV2.bottom(context),
            ),
          ),
          child: actions,
        ),
      ],
    );
  }
}
