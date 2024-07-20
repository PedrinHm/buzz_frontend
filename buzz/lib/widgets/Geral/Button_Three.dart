import 'package:flutter/material.dart';

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
      width: 189, // Largura fixa do botão
      height: 50, // Altura fixa do botão
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Cor do texto do botão
          backgroundColor: backgroundColor, // Usa a cor de fundo passada como parâmetro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
