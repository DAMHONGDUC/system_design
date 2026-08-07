part of 'sd_action_view_v2.dart';

/// Content and actions in one scroll view, the free space between them.
///
/// The [ConstrainedBox] is what gives `spaceBetween` something to spread:
/// without a minimum height the column shrink-wraps and short content leaves
/// the buttons floating in the middle of the screen.
class _Scrolling extends StatelessWidget {
  const _Scrolling({
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(
                top: SdContentPaddingV2.top(context),
                bottom: SdContentPaddingV2.bottom(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(padding: contentInsets, child: content),
                  Padding(padding: actionInsets, child: actions),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
