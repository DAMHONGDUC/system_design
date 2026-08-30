import 'package:flutter/material.dart';

class SdTextFieldV4 extends StatelessWidget {
  const SdTextFieldV4({
    required this.controller,
    required this.label,
    this.suffix,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
