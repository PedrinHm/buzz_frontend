import 'package:flutter/material.dart';

class ButtonTwo extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  ButtonTwo({
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
          borderRadius: BorderRadius.circular(10),  // Arredondamento das bordas
        ),
        fixedSize: Size(320, 70),  // Tamanho fixo do botão (largura x altura)
      ),
      child: Text(
        buttonText,  // Texto do botão passado como parâmetro
        style: TextStyle(
          fontSize: 16,  // Tamanho do texto
          fontWeight: FontWeight.normal,  // Peso da fonte
        ),
      ),
    );
  }
}
