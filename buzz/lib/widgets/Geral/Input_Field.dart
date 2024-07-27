import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;

  CustomInputField({
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: TextField(
            controller: controller,  // Certifique-se de usar o controlador aqui
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFD9D9D9),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
