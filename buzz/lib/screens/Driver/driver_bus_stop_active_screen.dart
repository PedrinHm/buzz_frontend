import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:flutter/material.dart';

class DriverActiveTripScreen extends StatelessWidget {
  final VoidCallback endTrip;

  DriverActiveTripScreen({required this.endTrip});

  final List<Map<String, String>> tripBusStops = [
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'Já passou'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'Já passou'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'Já passou'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'Já passou'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'Já passou'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'No ponto'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'Próximo ponto'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'A caminho'},
    {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'A caminho'},
  ];

  bool _allStopsPassed() {
    return tripBusStops.every((stop) => stop['status'] == 'Já passou');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: CustomTitleWidget(title: 'Viagem Atual - Pontos de Ônibus'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: tripBusStops.length,
              itemBuilder: (context, index) {
                final data = tripBusStops[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TripBusStop(
                    onPressed: () {
                      // Adicione a ação a ser executada ao pressionar
                    },
                    busStopName: data['name']!,
                    busStopStatus: data['status']!,
                  ),
                );
              },
            ),
          ),
          if (!_allStopsPassed())
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ButtonThree(
                      buttonText: 'Ônibus com problema',
                      backgroundColor: Color(0xFFCBB427),
                      onPressed: () {
                        print('Ônibus com problema Pressionado');
                        // Adicione a lógica para sinalizar problema no ônibus aqui
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ButtonThree(
                      buttonText: 'Selecionar destino',
                      backgroundColor: Color(0xFF3E9B4F),
                      onPressed: () {
                        print('Selecionar ponto de ônibus Pressionado');
                        // Adicione a lógica para selecionar o próximo ponto de ônibus aqui
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (_allStopsPassed())
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ButtonThree(
                  buttonText: 'Encerrar Viagem',
                  backgroundColor: Colors.red,
                  onPressed: endTrip,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


