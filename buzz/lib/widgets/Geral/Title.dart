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
      decoration: BoxDecoration(
        color: Color(0xFF395BC7),
        borderRadius: BorderRadius.circular(getHeightProportion(context, 10)), // Proporção de borda
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: getHeightProportion(context, 16),  // Tamanho do texto proporcional
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter', // Certifique-se de ter a fonte 'Inter' incluída no seu projeto
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
