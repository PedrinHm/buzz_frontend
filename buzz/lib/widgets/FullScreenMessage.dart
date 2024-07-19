import 'package:flutter/material.dart';

class FullScreenMessage extends StatelessWidget {
  final String message;

  FullScreenMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // 90% da largura da tela
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05), // Centraliza o container
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 10 pixels de padding em todas as direções
        decoration: BoxDecoration(
          color: Colors.transparent, // Fundo transparente
          borderRadius: BorderRadius.circular(10), // Bordas arredondadas em 10px
          border: Border.all(color: Colors.black, width: 1), // Bordas pretas
        ),
        alignment: Alignment.topLeft, // Alinha o texto no começo (esquerda) do widget
        child: Text(
          message,
          style: TextStyle(fontSize: 36), // Ajuste o tamanho do texto conforme necessário
          textAlign: TextAlign.left, // Texto alinhado à esquerda
        ),
      ),
    );
  }
}
