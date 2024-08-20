import 'package:flutter/material.dart';
import 'package:buzz/widgets/Driver/Bus_Selection_Dialog.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';

class StudentHomeTripInactiveScreen extends StatelessWidget {
  void _handleBusSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BusSelectionDialog(
          onBusSelected: (int busId) {
            // Implemente a lógica após a seleção do ônibus aqui
            Navigator.pop(context);  // Fechar o diálogo após a seleção
          },
          url: 'http://127.0.0.1:8000/buses/trips/active_trips',
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Você não está em nenhuma viagem atualmente.',
                  style: TextStyle(
                    color: Color(0xFF000000).withOpacity(0.70),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Botão fixo na parte inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ButtonThree(
                buttonText: 'Selecionar viagem',
                backgroundColor: Color(0xFF395BC7),
                onPressed: () => _handleBusSelection(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
