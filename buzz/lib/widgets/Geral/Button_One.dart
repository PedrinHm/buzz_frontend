import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart'; // Import das funções de proporção

class Button_One extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  Button_One({
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Ação do botão passada como parâmetro
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF395BC7),  // Cor de fundo do botão
        foregroundColor: Colors.white,       // Cor do texto e ícones
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidthProportion(context, 10)),  // Proporção aplicada
        ),
        padding: EdgeInsets.symmetric(
          horizontal: getWidthProportion(context, 48),  // Proporção aplicada
          vertical: getHeightProportion(context, 24),   // Proporção aplicada
        ),
        minimumSize: Size(
          getWidthProportion(context, 160),   // Proporção aplicada
          getHeightProportion(context, 48),   // Proporção aplicada
        ),  // Tamanho mínimo para o botão
      ),
      child: Text(
        buttonText,  // Texto do botão passado como parâmetro
        style: TextStyle(
          fontSize: getHeightProportion(context, 16),  // Proporção aplicada
          fontWeight: FontWeight.normal,  // Peso da fonte
        ),
      ),
    );
  }
}
