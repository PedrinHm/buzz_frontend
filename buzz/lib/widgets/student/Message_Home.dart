import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class FullScreenMessage extends StatelessWidget {
  final String message;

  FullScreenMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // 90% da largura da tela
        margin: EdgeInsets.symmetric(horizontal: getWidthProportion(context, 0.05)), // Centraliza o container
        padding: EdgeInsets.symmetric(
          horizontal: getWidthProportion(context, 20), 
          vertical: getHeightProportion(context, 20), // Proporção de padding
        ),
        decoration: BoxDecoration(
          color: Colors.transparent, // Fundo transparente
          borderRadius: BorderRadius.circular(getHeightProportion(context, 10)), // Proporção de bordas arredondadas
          border: Border.all(color: Colors.black, width: 1), // Bordas pretas
        ),
        alignment: Alignment.topLeft, // Alinha o texto no começo (esquerda) do widget
        child: Text(
          message,
          style: TextStyle(
            fontSize: getHeightProportion(context, 36), // Tamanho do texto proporcional
          ),
          textAlign: TextAlign.left, // Texto alinhado à esquerda
        ),
      ),
    );
  }
}
