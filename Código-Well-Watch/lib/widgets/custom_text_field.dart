import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final Icon? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator, // agora usa o parâmetro corretamente
        style: TextStyle(color: primaryColor),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: primaryColor.withOpacity(0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
