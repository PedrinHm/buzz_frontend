import 'package:provider/provider.dart'; // Certifique-se de que o Provider esteja importado
import 'package:buzz/widgets/Student/Bus_Button_Home.dart';
import 'package:buzz/widgets/Student/Bus_Stop_Button_Home.dart';
import 'package:buzz/widgets/Student/Message_Home.dart';
import 'package:buzz/widgets/Student/Status_Button_Home.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Student/status_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentHomeTripActiveScreen extends StatefulWidget {
  final int studentId; 
  final int tripId; 
  final int studentTripId; 

  StudentHomeTripActiveScreen({
    required this.studentId, 
    required this.tripId, 
    required this.studentTripId,
  });

  @override
  _StudentHomeTripActiveScreenState createState() => _StudentHomeTripActiveScreenState();
}

class _StudentHomeTripActiveScreenState extends State<StudentHomeTripActiveScreen> {
  bool _showBusOverlay = false;
  bool _showBusStopOverlay = false;
  bool _showStatusOverlay = false; // Flag para a sobreposição de status
  List<Map<String, dynamic>> _busList = []; // Lista de ônibus disponíveis
  List<Map<String, String>> busStopList = []; // Lista de pontos de ônibus
  bool isLoading = false; // Flag de carregamento
  late int _studentTripId; // Use late para garantir que será inicializado

  @override
  void initState() {
    super.initState();
    _studentTripId = widget.studentTripId; // Inicializa _studentTripId com o valor do widget
  }

  void _toggleBusOverlay() {
    setState(() {
      _showBusOverlay = !_showBusOverlay;
      if (_showBusOverlay) {
        _fetchActiveBuses(); // Carrega a lista de ônibus ativos
      }
    });
  }

  void _toggleBusStopOverlay() {
    setState(() {
      _showBusStopOverlay = !_showBusStopOverlay;
      if (_showBusStopOverlay) {
        _fetchBusStops(); // Carregar os pontos de ônibus quando a sobreposição for ativada
      }
    });
  }

  void _toggleStatusOverlay() {
    setState(() {
      _showStatusOverlay = !_showStatusOverlay;
    });
  }

  Future<void> _fetchActiveBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Realiza a chamada HTTP para buscar ônibus disponíveis para o aluno
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/buses/available_for_student?student_id=${widget.studentId}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          _busList = data.map((item) => {
            'busId': item['bus_id'],
            'tripId': item['trip_id'],
            'registrationNumber': item['registration_number'],
            'name': item['name'],
            'capacity': item['capacity'],
            'tripType': item['trip_type'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load available buses for student');
      }
    } catch (e) {
      print('Error fetching available buses for student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar ônibus disponíveis para o aluno')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBusStops() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Utilize o ID do aluno e da viagem a partir do widget
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/bus_stops/action/trip?student_id=${widget.studentId}&trip_id=${widget.tripId}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          busStopList = data.map((item) => {
            'id': item['id'].toString(), // Certifique-se de que 'id' está presente e convertido para String
            'name': item['name'] as String,
            'status': item['status'] as String,
          }).toList();
        });
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateStudentTrip(int newTripId) async {
    if (_studentTripId == null) {
      print('Student trip ID is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: Student trip ID não está definido!')),
      );
      return;
    }

    try {
      // Realiza a chamada HTTP para atualizar a viagem do aluno
      final response = await http.put(Uri.parse('http://127.0.0.1:8000/student_trips/$_studentTripId/update_trip?new_trip_id=$newTripId'));

      if (response.statusCode == 200) {
        print('Viagem do aluno atualizada com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viagem do aluno atualizada com sucesso!')),
        );
      } else {
        throw Exception('Failed to update student trip');
      }
    } catch (e) {
      print('Erro ao atualizar a viagem do aluno: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar a viagem do aluno')),
      );
    }
  }

  Future<void> _updateStudentTripPoint(int pointId) async {
    if (_studentTripId == null) {
      print('Student trip ID is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: Student trip ID não está definido!')),
      );
      return;
    }

    try {
      // Monta a URL com o ID da viagem do aluno e o novo ponto
      final url = Uri.parse('http://127.0.0.1:8000/student_trips/$_studentTripId/update_point?point_id=$pointId');

      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('Ponto de ônibus atualizado com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ponto de ônibus atualizado com sucesso!')),
        );
      } else {
        throw Exception('Failed to update bus stop point');
      }
    } catch (e) {
      print('Erro ao atualizar o ponto de ônibus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar o ponto de ônibus')),
      );
    }
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
                  onPressed: _toggleStatusOverlay, // Adicione esta linha para definir o callback
                  StatusName: 'Definir status', // Texto atualizado para indicar o propósito do botão
                  iconData: PhosphorIcons.chalkboardTeacher,
                ),
                SizedBox(height: 10),
                CustomBusStopButton(
                  onPressed: _toggleBusStopOverlay,
                  busStopName: "Definir ponto de ônibus",
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
              isLoading ? CircularProgressIndicator() : _buildBusStopList(),
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
    return ListView.builder(
      itemCount: _busList.length,
      itemBuilder: (context, index) {
        final bus = _busList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: BusDetailsButton(
            onPressed: () {
              _updateStudentTrip(bus['tripId']); // Chama a função para atualizar a viagem do aluno
              _toggleBusOverlay();
            },
            busNumber: bus['registrationNumber'],
            driverName: bus['name'],
            capacity: bus['capacity'],
            availableSeats: 0, // Defina isso de acordo com os dados recebidos, se necessário
            color: Color(0xFF395BC7),
          ),
        );
      },
    );
  }

  Widget _buildBusStopList() {
    return ListView.builder(
      itemCount: busStopList.length,
      itemBuilder: (context, index) {
        final busStop = busStopList[index];
        final busStopId = busStop['id'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: TripBusStop(
            onPressed: () {
              if (busStopId != null) {
                print("Selecionado ponto de ônibus: ${busStop['name']}");
                _updateStudentTripPoint(int.parse(busStopId)); // Chama a função para atualizar o ponto
              } else {
                print('Erro: ID do ponto de ônibus é nulo');
              }
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
