import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class TextLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  TextLinkButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black.withOpacity(0.7),
        textStyle: TextStyle(
          fontSize: getHeightProportion(context, 16),  // Tamanho do texto proporcional
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(text),
    );
  }
}
