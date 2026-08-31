import 'package:flutter/material.dart';

import '../sd_content_padding_v4/sd_content_padding_v4.dart';

final class SdActionViewV4 extends StatelessWidget {
  const SdActionViewV4({required this.body, required this.actions, super.key})
    : assert(actions.length > 0);

  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Expanded(child: body),
      ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: SdContentPaddingV4.bottomActions(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int index = 0; index < actions.length; index++) ...<Widget>[
                actions[index],
                if (index != actions.length - 1)
                  SizedBox(height: SdContentPaddingV4.listItemGap),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}
