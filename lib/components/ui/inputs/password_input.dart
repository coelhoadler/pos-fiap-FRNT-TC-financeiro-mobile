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
      style: TextStyle(fontSize: 16, color: Color(0xFF004d61)),
      decoration: InputDecoration(
        labelText: widget.label ?? 'Senha *',
        labelStyle: TextStyle(
          color: Color(0xFF004d61),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF004d61)), 
        ),
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
