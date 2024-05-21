import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextFormField TelefoneResidencial(TextEditingController _telefoneController) {

  return TextFormField(
      controller: _telefoneController,
      decoration: InputDecoration(labelText: 'Telefone Residencial'),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          final newText = StringBuffer();
          if (text.length <= 2) {
            newText.write(text.substring(0, text.length));
          } else if (text.length > 2 && text.length <= 6) {
            newText.write(text.substring(0, 2) + '-' + text.substring(2, text.length));
          } else if (text.length > 6) {
            newText.write(text.substring(0, 2) + '-' + text.substring(2, 6) + '-' + text.substring(6, text.length));
          }
          return TextEditingValue(
            text: newText.toString(),
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, digite um numero de telefone valido';
        }
        // Add your validation logic here if needed
        return null;
      },
    );
  }
