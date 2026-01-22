/// Email Input Field Widget
/// 
/// Reusable email input with built-in validation
library;

import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final TextInputAction textInputAction;

  const EmailField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Email',
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      validator: validator ??
          (value) {
            if (value?.isEmpty ?? true) {
              return 'Email is required';
            }
            if (!value!.contains('@')) {
              return 'Invalid email format';
            }
            return null;
          },
    );
  }
}
