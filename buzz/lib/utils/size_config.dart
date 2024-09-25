import 'package:flutter/material.dart';

// Função para calcular a proporção da altura da tela
double getHeightProportion(BuildContext context, double inputHeight) {
  return (inputHeight / 932) * MediaQuery.of(context).size.height;
}

// Função para calcular a proporção da largura da tela
double getWidthProportion(BuildContext context, double inputWidth) {
  return (inputWidth / 430) * MediaQuery.of(context).size.width;
}
