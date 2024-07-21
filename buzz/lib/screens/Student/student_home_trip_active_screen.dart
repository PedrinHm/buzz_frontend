import 'package:buzz/widgets/Student/Bus_Button_Home.dart';
import 'package:buzz/widgets/Student/Bus_Stop_Button_Home.dart';
import 'package:buzz/widgets/Student/Message_Home.dart';
import 'package:buzz/widgets/Student/Status_Button_Home.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';

class StudentHomeTripActiveScreen extends StatefulWidget {
  @override
  _StudentHomeTripActiveScreenState createState() => _StudentHomeTripActiveScreenState();
}

class _StudentHomeTripActiveScreenState extends State<StudentHomeTripActiveScreen> {
  bool _showOverlay = false;

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                FullScreenMessage(
                  message: 'Existem ônibus em viagem de ida, está participando?',
                ),
                SizedBox(height: 10),
                CustomStatus(
                  onPressed: () {
                    // Defina o que acontece quando o botão é pressionado
                  },
                  StatusName: 'Em aula',
                  iconData: PhosphorIcons.chalkboardTeacher, // Aqui você passa o ícone desejado
                ),
                SizedBox(height: 10),
                CustomBusStopButton(
                  onPressed: () {
                    print("Botão pressionado");
                  },
                  busStopName: "ABC-1234",
                ),
                SizedBox(height: 10),
                CustomBusButton(
                  onPressed: _toggleOverlay,
                  busNumber: "ABC-1234",
                  driverName: "Nome Do Motorista",
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          if (_showOverlay)
            Container(
              color: Colors.black.withOpacity(0.9),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Text(
                    'Defina seu ônibus atual',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: _buildBusList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ButtonThree(
                      buttonText: 'Cancelar',
                      backgroundColor: Colors.red,
                      onPressed: _toggleOverlay,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBusList() {
    final List<Map<String, dynamic>> busList = [
      {'busNumber': 'XYZ-5678', 'driverName': 'Motorista 1', 'capacity': 56, 'availableSeats': 10, 'available': true},
      {'busNumber': 'JKL-9101', 'driverName': 'Motorista 2', 'capacity': 56, 'availableSeats': 0, 'available': false},
      // Adicione mais ônibus conforme necessário
    ];

    return ListView.builder(
      itemCount: busList.length,
      itemBuilder: (context, index) {
        final bus = busList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: BusDetailsButton(
            onPressed: () {
              print("Selecionado ônibus: ${bus['busNumber']}");
              _toggleOverlay();
            },
            busNumber: bus['busNumber'],
            driverName: bus['driverName'],
            capacity: bus['capacity'],
            availableSeats: bus['availableSeats'],
            color: bus['available'] ? Color(0xFF395BC7) : Color(0xFFFFBA18),
          ),
        );
      },
    );
  }
}
