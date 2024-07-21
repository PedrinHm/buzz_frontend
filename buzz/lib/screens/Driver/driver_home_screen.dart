import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Geral/button_one.dart'; // Importa o botão // Importa a barra de navegação

class DriverHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nenhuma viagem em andamento.',
                  style: TextStyle(
                    color: Color(0xFF000000).withOpacity(0.70),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20.0, // Ajuste esta altura conforme necessário
            left: 0,
            right: 0,
            child: Center(
              child: Button_One(
                buttonText: 'Iniciar Viagem',
                onPressed: () {
                  print('Iniciar Viagem Pressionado');
                  // Adicione a lógica para iniciar a viagem aqui
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
