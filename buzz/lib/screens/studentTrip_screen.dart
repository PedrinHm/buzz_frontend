import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/CustomTitleWidget.dart';
import '/widgets/bottom_nav_bar.dart';
import '/widgets/TripBusStop.dart'; // Importa o novo componente

class StudentTripScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dados simulados
    final List<Map<String, String>> simulatedData = [
      {'name': 'Bloco I - Universidade de Rio Verde', 'status': 'Já passou'},
      {'name': 'Bloco VI - Universidade de Rio Verde', 'status': 'Já passou'},
      {'name': 'UniRV Centro - Universidade de Rio Verde', 'status': 'Já passou'},
      {'name': 'IF - Instituto Federal', 'status': 'No ponto'},
      {'name': 'Ponto C', 'status': 'Proximo ponto'},
      {'name': 'Ponto D', 'status': 'A caminho'},
      {'name': 'Ponto E', 'status': 'A caminho'},
      //{'name': 'Ponto E', 'status': 'Ônibus com problema'},
    ];

    // Função para gerar widgets dinamicamente
    List<Widget> _generateTripBusStopWidgets() {
      return simulatedData.map((data) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TripBusStop(
            onPressed: () {
              // Adicione a ação a ser executada ao pressionar
            },
            busStopName: data['name']!,
            busStopStatus: data['status']!,
          ),
        );
      }).toList();
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            CustomTitleWidget(title: 'Viagem atual'),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _generateTripBusStopWidgets(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
