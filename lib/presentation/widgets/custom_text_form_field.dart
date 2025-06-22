import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? initialValue;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon; // ADDED

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.labelText,
    this.initialValue,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon, // ADDED
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Theme.of(context).primaryColor)
            : null, // ADDED
      ),
    );
  }
}
