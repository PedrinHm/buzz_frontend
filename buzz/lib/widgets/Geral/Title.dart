import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class CustomTitleWidget extends StatelessWidget {
  final String title;

  CustomTitleWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      height: getHeightProportion(context, 50),  // Proporção de altura
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF395BC7),
          fontSize: getHeightProportion(context, 24),  // Tamanho do texto proporcional
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter', // Certifique-se de ter a fonte 'Inter' incluída no seu projeto
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
