import 'package:flutter/material.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/utils/size_config.dart'; // Import das funções de proporção

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
          SizedBox(height: getHeightProportion(context, 40)), // Proporção aplicada
          Text(
            'Defina seu ponto de ônibus atual',
            style: TextStyle(
              color: Colors.white,
              fontSize: getHeightProportion(context, 24), // Proporção aplicada
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getHeightProportion(context, 20)), // Proporção aplicada
          Expanded(
            child: _buildBusStopList(context),
          ),
          Padding(
            padding: EdgeInsets.all(getHeightProportion(context, 20.0)), // Proporção aplicada
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

  Widget _buildBusStopList(BuildContext context) {
    return ListView.builder(
      itemCount: busStops.length,
      itemBuilder: (context, index) {
        final busStop = busStops[index];
        return Padding(
          padding: EdgeInsets.only(bottom: getHeightProportion(context, 20.0)), // Proporção aplicada
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
