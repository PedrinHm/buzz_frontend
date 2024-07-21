import 'package:buzz/widgets/Student/Bus_Button_Home.dart';
import 'package:buzz/widgets/Student/Bus_Stop_Button_Home.dart';
import 'package:buzz/widgets/Student/Message_Home.dart';
import 'package:buzz/widgets/Student/Status_Button_Home.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Student/status_button.dart'; // Importa o novo componente

class StudentHomeTripActiveScreen extends StatefulWidget {
  @override
  _StudentHomeTripActiveScreenState createState() => _StudentHomeTripActiveScreenState();
}

class _StudentHomeTripActiveScreenState extends State<StudentHomeTripActiveScreen> {
  bool _showBusOverlay = false;
  bool _showBusStopOverlay = false;
  bool _showStatusOverlay = false; // Flag para a sobreposição de status

  void _toggleBusOverlay() {
    setState(() {
      _showBusOverlay = !_showBusOverlay;
    });
  }

  void _toggleBusStopOverlay() {
    setState(() {
      _showBusStopOverlay = !_showBusStopOverlay;
    });
  }

  void _toggleStatusOverlay() {
    setState(() {
      _showStatusOverlay = !_showStatusOverlay;
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
                  onPressed: _toggleStatusOverlay,
                  StatusName: 'Em aula',
                  iconData: PhosphorIcons.chalkboardTeacher, // Aqui você passa o ícone desejado
                ),
                SizedBox(height: 10),
                CustomBusStopButton(
                  onPressed: _toggleBusStopOverlay,
                  busStopName: "ABC-1234",
                ),
                SizedBox(height: 10),
                CustomBusButton(
                  onPressed: _toggleBusOverlay,
                  busNumber: "ABC-1234",
                  driverName: "Nome Do Motorista",
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          if (_showBusOverlay)
            _buildOverlay(
              'Defina seu ônibus atual',
              _buildBusList(),
              _toggleBusOverlay,
            ),
          if (_showBusStopOverlay)
            _buildOverlay(
              'Defina seu ponto de ônibus atual',
              _buildBusStopList(),
              _toggleBusStopOverlay,
            ),
          if (_showStatusOverlay)
            _buildOverlay(
              'Defina seu status atual',
              _buildStatusList(),
              _toggleStatusOverlay,
            ),
        ],
      ),
    );
  }

  Widget _buildOverlay(String title, Widget content, VoidCallback onCancel) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Column(
        children: [
          SizedBox(height: 40),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: content,
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
              _toggleBusOverlay();
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

  Widget _buildBusStopList() {
    final List<Map<String, String>> busStopList = [
      {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'No ponto'},
      {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'Próximo ponto'},
      {'name': 'Universidade de Rio Verde - Bloco I', 'status': 'A caminho'},
      // Adicione mais pontos conforme necessário
    ];

    return ListView.builder(
      itemCount: busStopList.length,
      itemBuilder: (context, index) {
        final busStop = busStopList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: TripBusStop(
            onPressed: () {
              print("Selecionado ponto de ônibus: ${busStop['name']}");
              _toggleBusStopOverlay();
            },
            busStopName: busStop['name']!,
            busStopStatus: busStop['status']!,
          ),
        );
      },
    );
  }

  Widget _buildStatusList() {
    final List<Map<String, dynamic>> statusList = [
      {'statusText': 'Em aula', 'color': Color(0xFF395BC7), 'icon': PhosphorIcons.chalkboardTeacher},
      {'statusText': 'Aguardando ônibus', 'color': Color(0xFFB0E64C), 'icon': PhosphorIcons.bus},
      {'statusText': 'Presente', 'color': Color(0xFF3E9B4F), 'icon': PhosphorIcons.check},
      {'statusText': 'Não voltará', 'color': Color(0xFFFFBA18), 'icon': PhosphorIcons.x},
      // Adicione mais status conforme necessário
    ];

    return ListView.builder(
      itemCount: statusList.length,
      itemBuilder: (context, index) {
        final status = statusList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: StatusButton(
            onPressed: () {
              print("Selecionado status: ${status['statusText']}");
              _toggleStatusOverlay();
            },
            statusText: status['statusText'],
            color: status['color'],
            icon: status['icon'],
          ),
        );
      },
    );
  }
}
