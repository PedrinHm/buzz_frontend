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
  bool _showStatusOverlay = false; 
  List<Map<String, dynamic>> _busList = []; 
  List<Map<String, String>> busStopList = []; 
  List<Map<String, dynamic>> _statusList = []; // Lista de status disponíveis
  bool isLoading = false; 
  late int _studentTripId; 
  int? _currentStatus; // Status atual do aluno como int

  // Mapeamento de status numérico para rótulos e cores
  final Map<int, Map<String, dynamic>> statusDetails = {
    1: {'statusText': 'Presente', 'color': Color(0xFF3E9B4F), 'icon': PhosphorIcons.check},
    2: {'statusText': 'Em aula', 'color': Color(0xFF395BC7), 'icon': PhosphorIcons.chalkboardTeacher},
    3: {'statusText': 'Aguardando ônibus', 'color': Color(0xFFB0E64C), 'icon': PhosphorIcons.bus},
    4: {'statusText': 'Não voltará', 'color': Color(0xFFFFBA18), 'icon': PhosphorIcons.x},
    5: {'statusText': 'Fila de espera', 'color': Color(0xFFFFBA18), 'icon': PhosphorIcons.x},
  };

  @override
  void initState() {
    super.initState();
    _studentTripId = widget.studentTripId; 
    _fetchCurrentStatus(); // Inicializa o status atual
  }

  void _toggleBusOverlay() {
    setState(() {
      _showBusOverlay = !_showBusOverlay;
      if (_showBusOverlay) {
        _fetchActiveBuses(); 
      }
    });
  }

  void _toggleBusStopOverlay() {
    setState(() {
      _showBusStopOverlay = !_showBusStopOverlay;
      if (_showBusStopOverlay) {
        _fetchBusStops(); 
      }
    });
  }

  void _toggleStatusOverlay() {
    setState(() {
      _showStatusOverlay = !_showStatusOverlay;
      if (_showStatusOverlay) {
        _fetchAvailableStatus(); // Carrega a lista de status disponíveis
      }
    });
  }

  Future<void> _fetchCurrentStatus() async {
    try {
      // Faz uma chamada HTTP para buscar o status atual do aluno
      final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/student_trips/${widget.studentTripId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentStatus = data['status']; // status numérico recebido da API
        });
      } else {
        throw Exception('Failed to fetch current status');
      }
    } catch (e) {
      print('Error fetching current status: $e');
    }
  }

  Future<void> _fetchAvailableStatus() async {
    if (_currentStatus == null) {
      print('Current status is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: Status atual não está definido!')),
      );
      return;
    }

    // Definindo os status permitidos para cada status atual
    final Map<int, List<int>> allowedTransitions = {
      1: [2, 3, 4], // Presente para Em aula, Aguardando ônibus, Não voltará
      2: [1, 3, 4], // Em aula para Presente, Aguardando ônibus, Não voltará
      3: [1, 2, 4], // Aguardando ônibus para Presente, Em aula, Não voltará
      4: [1, 2, 3, 5], // Não voltará para Presente, Em aula, Aguardando ônibus, Fila de espera
      5: [1, 2, 3, 4] // Fila de espera para Presente, Em aula, Aguardando ônibus, Não voltará
    };

    final List<int>? possibleStatuses = allowedTransitions[_currentStatus];

    if (possibleStatuses == null) {
      print('Erro: Transições permitidas não encontradas para o status atual!');
      return;
    }

    setState(() {
      // Cria uma lista de opções de status permitidos com base no status atual
      _statusList = possibleStatuses.map((status) => {
        'status': status,
        ...statusDetails[status]!,
      }).toList();
    });
  }

  Future<void> _updateStudentTripStatus(int newStatus) async {
    if (_studentTripId == null) {
      print('Student trip ID is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: Student trip ID não está definido!')),
      );
      return;
    }

    try {
      final url = Uri.parse('https://buzzbackend-production.up.railway.app/student_trips/$_studentTripId/update_status?new_status=$newStatus');

      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('Status do aluno atualizado com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status do aluno atualizado com sucesso!')),
        );
      } else {
        throw Exception('Failed to update student status');
      }
    } catch (e) {
      print('Erro ao atualizar o status do aluno: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar o status do aluno')),
      );
    }
  }

  Future<void> _fetchActiveBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/buses/available_for_student?student_id=${widget.studentId}'));

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
      final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/bus_stops/action/trip?student_id=${widget.studentId}&trip_id=${widget.tripId}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          busStopList = data.map((item) => {
            'id': item['id'].toString(),
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
      final response = await http.put(Uri.parse('https://buzzbackend-production.up.railway.app/student_trips/$_studentTripId/update_trip?new_trip_id=$newTripId'));

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
      final url = Uri.parse('https://buzzbackend-production.up.railway.app/student_trips/$_studentTripId/update_point?point_id=$pointId');

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
                  onPressed: _toggleStatusOverlay,
                  StatusName: 'Definir status',
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
              _updateStudentTrip(bus['tripId']);
              _toggleBusOverlay();
            },
            busNumber: bus['registrationNumber'],
            driverName: bus['name'],
            capacity: bus['capacity'],
            availableSeats: 0,
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
                _updateStudentTripPoint(int.parse(busStopId));
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
    return ListView.builder(
      itemCount: _statusList.length,
      itemBuilder: (context, index) {
        final status = _statusList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: StatusButton(
            onPressed: () {
              _updateStudentTripStatus(status['status']);
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
