import 'package:flutter/material.dart';

class TextFormFieldGenerico extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? validationMessage;
  final TextInputType keyboardType;
  final bool enabled;

  TextFormFieldGenerico({
    required this.controller,
    required this.label,
    this.validationMessage,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      enabled: enabled,
    );
  }
}
