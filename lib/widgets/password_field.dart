import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final Function(String)? onChanged; // Add onChanged parameter
  final VoidCallback? onTap; // Add onTap parameter

  const PasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.enabled = true,
    this.onChanged, // Add onChanged parameter
    this.onTap, // Add onTap parameter
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: widget.enabled,
      onChanged: widget.onChanged, // Add onChanged callback
      onTap: widget.onTap, // Add onTap callback
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
          color: KStyle.c72GreyColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KStyle.cE3GreyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KStyle.cE3GreyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KStyle.cPrimaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: KStyle.c72GreyColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: widget.validator,
    );
  }
}
