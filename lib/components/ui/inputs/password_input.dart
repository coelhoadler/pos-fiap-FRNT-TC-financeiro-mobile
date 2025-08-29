import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;

  const PasswordInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label ?? 'Password *',
        hintText: widget.hint,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
        ),
      ),
    );
  }
}
