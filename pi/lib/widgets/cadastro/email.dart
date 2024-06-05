import 'package:flutter/material.dart';

TextFormField Email(TextEditingController _emailController) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o email';
        }
        if (!isValidEmail(value)) {
          return 'Por favor, insira um email válido';
        }
        return null;
      },
    );  
  }
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
