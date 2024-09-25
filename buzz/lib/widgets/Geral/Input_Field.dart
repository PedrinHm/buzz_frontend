import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class CustomInputField extends StatefulWidget {
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final bool enabled;

  CustomInputField({
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.controller,
    this.enabled = true,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.labelText,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: getHeightProportion(context, 16.0),  // Tamanho do texto proporcional
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFD9D9D9),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                borderRadius: BorderRadius.circular(getHeightProportion(context, 10)),  // Proporção de borda
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 2),
                borderRadius: BorderRadius.circular(getHeightProportion(context, 10)),  // Proporção de borda
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Opacity(
                        opacity: 0.5, // Define a opacidade do ícone
                        child: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
