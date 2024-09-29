import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart'; // Import das funções de proporção

class ButtonThree extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color backgroundColor; // Adiciona a cor de fundo como parâmetro

  ButtonThree({
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor, // Inicializa a cor de fundo
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidthProportion(context, 189), // Proporção aplicada na largura
      height: getHeightProportion(context, 50), // Proporção aplicada na altura
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Cor do texto do botão
          backgroundColor: backgroundColor, // Usa a cor de fundo passada como parâmetro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(getWidthProportion(context, 10)), // Proporção aplicada
          ),
        ),
        child: Center( // Garante que o texto fique centralizado
          child: Text(
            buttonText,
            style: TextStyle(fontSize: getHeightProportion(context, 16)), // Proporção aplicada no tamanho do texto
          ),
        ),
      ),
    );
  }
}
