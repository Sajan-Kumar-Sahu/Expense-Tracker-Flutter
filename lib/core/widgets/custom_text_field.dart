import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard custom input text field that conforms to AppTheme input decoration styling.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }
}
