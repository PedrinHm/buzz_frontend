import 'package:flutter/material.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';

class BusStopSelectionOverlay extends StatelessWidget {
  final VoidCallback onCancel;
  final void Function(String busStopName) onBusStopSelected;
  final List<Map<String, dynamic>> busStops; // Adicione esta linha para definir o parâmetro 'busStops'

  BusStopSelectionOverlay({
    required this.onCancel,
    required this.onBusStopSelected,
    required this.busStops, // Inclua 'busStops' como parâmetro obrigatório
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Column(
        children: [
          SizedBox(height: 40),
          Text(
            'Defina seu ponto de ônibus atual',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildBusStopList(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ButtonThree(
              buttonText: 'Cancelar',
              backgroundColor: Colors.red,
              onPressed: onCancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusStopList() {
    return ListView.builder(
      itemCount: busStops.length,
      itemBuilder: (context, index) {
        final busStop = busStops[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: TripBusStop(
            onPressed: () {
              print("Selecionado ponto de ônibus: ${busStop['name']}");
              onBusStopSelected(busStop['name']);
            },
            busStopName: busStop['name'],
            busStopStatus: busStop['status'],
          ),
        );
      },
    );
  }
}
