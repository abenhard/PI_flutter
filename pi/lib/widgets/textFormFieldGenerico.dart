
import 'package:flutter/material.dart';

TextFormField TextFormFieldGenerico(TextEditingController controller, String label, String? validationMessage, [TextInputType keyboardType = TextInputType.text]) {
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
    );
  }