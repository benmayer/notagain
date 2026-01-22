/// Password Input Field Widget
/// 
/// Reusable password input with visibility toggle and validation
library;

import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final bool isConfirmation;
  final TextEditingController? passwordController;

  const PasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Password',
    this.isConfirmation = false,
    this.passwordController,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _showPassword = !_showPassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: !_showPassword,
      validator: widget.validator ??
          (value) {
            if (value?.isEmpty ?? true) {
              return '${widget.hintText} is required';
            }
            if (!widget.isConfirmation && (value?.length ?? 0) < 6) {
              return 'Password must be at least 6 characters';
            }
            if (widget.isConfirmation && value != widget.passwordController?.text) {
              return 'Passwords do not match';
            }
            return null;
          },
    );
  }
}
