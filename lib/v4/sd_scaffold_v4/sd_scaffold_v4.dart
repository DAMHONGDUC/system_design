import 'package:flutter/material.dart';

class SdScaffoldV4 extends StatelessWidget {
  const SdScaffoldV4({
    required this.title,
    required this.body,
    this.showAppBar = true,
    super.key,
  });

  final String title;
  final Widget body;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: body,
    );
  }
}
