import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  CustomElevatedButton({
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
        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),  // Espaçamento interno
        minimumSize: Size(160, 48),  // Tamanho mínimo para o botão
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
