import 'package:buzz/widgets/Driver/Bus_Selection_Dialog.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart'; // Importar funções de tamanho

class StudentBusStopInactiveScreen extends StatelessWidget {
  final Future<void> Function(int driverId, int busId) startTrip;
  final int driverId;

  StudentBusStopInactiveScreen({required this.startTrip, required this.driverId});

Future<void> _showBusSelectionDialog(BuildContext context) async {
  final busId = await showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent, // Para mostrar o overlay
        child: _buildOverlay(
          'Selecione um Ônibus',
          BusSelectionDialog(
            onBusSelected: (selectedBusId) {
              Navigator.of(context).pop(selectedBusId);
            },
            url: 'https://buzzbackend-production.up.railway.app/buses/available',
          ),
          () => Navigator.of(context).pop(), // Função para cancelar
        ),
      );
    },
  );

  if (busId != null) {
    await startTrip(driverId, busId);
  }
}


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
                    fontSize: getHeightProportion(context, 16),  // Proporção ajustada
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: getHeightProportion(context, 20.0),  // Proporção ajustada
            left: 0,
            right: 0,
            child: Center(
              child: ButtonThree(
                buttonText: 'Iniciar Viagem',
                onPressed: () => _showBusSelectionDialog(context),
                backgroundColor: Color(0xFF395BC7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
