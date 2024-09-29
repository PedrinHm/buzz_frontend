import 'package:buzz/controllers/trip_controller.dart';
import 'package:buzz/utils/size_config.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/buildOverlay.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:provider/provider.dart';

class StudentHomeTripInactiveScreen extends StatefulWidget {
  final int studentId;

  StudentHomeTripInactiveScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentHomeTripInactiveScreenState createState() => _StudentHomeTripInactiveScreenState();
}

class _StudentHomeTripInactiveScreenState extends State<StudentHomeTripInactiveScreen> {
  bool _showBusOverlay = false;
  bool _showBusStopOverlay = false;
  bool isLoading = false;
  bool isCreatingTrip = false; 
  List<Map<String, dynamic>> _busList = [];
  List<Map<String, dynamic>> _busStopList = [];
  int _selectedTripId = 0; // Armazena o tripId selecionado
  int _selectedBusStopId = 0; // Armazena o busStopId selecionado

  // Função para buscar as viagens disponíveis
  Future<void> _fetchActiveBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/buses/available'));

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
        throw Exception('Failed to load available buses');
      }
    } catch (e) {
      print('Error fetching active buses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar viagens ativas')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para buscar os pontos de ônibus com base no tripId selecionado
  Future<void> _fetchBusStops(int tripId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/bus_stops/action/trip?student_id=${widget.studentId}&trip_id=$tripId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          _busStopList = data.map((item) => {
            'id': item['id'].toString(),
            'name': item['name'],
            'status': item['status'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar pontos de ônibus')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para criar o student_trip
  Future<void> _createStudentTrip(int tripId, int pointId) async {
    setState(() {
      isCreatingTrip = true;
    });

    final url = 'https://buzzbackend-production.up.railway.app/student_trips/';
    final body = json.encode({
      'trip_id': tripId,
      'student_id': widget.studentId,
      'point_id': pointId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        // Após a criação da viagem, tenta buscar o student_trip_id
        await _waitForStudentTripId(widget.studentId, tripId);
      } else {
        print('Erro ao criar viagem: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar viagem do estudante')),
        );
      }
    } catch (e) {
      print('Erro ao criar viagem: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar viagem do estudante')),
      );
    } finally {
      setState(() {
        isCreatingTrip = false;  // Esconde o indicador de carregamento após a criação da viagem
      });
    }
  }

  Future<void> _waitForStudentTripId(int studentId, int tripId) async {
    int retryCount = 0;
    const int maxRetries = 10;  // Número máximo de tentativas
    const Duration retryDelay = Duration(seconds: 2);  // Tempo entre tentativas

    while (retryCount < maxRetries) {
      try {
        // Faz a requisição para verificar se o student_trip_id foi gerado
        final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/student_trips/active/$studentId'));

        if (response.statusCode == 200) {
          final tripData = json.decode(response.body);
          final studentTripId = tripData['student_trip_id'];

          if (studentTripId != null) {
            // Atualiza o TripController com a nova viagem
            final tripController = Provider.of<TripController>(context, listen: false);
            tripController.startStudentTrip(studentTripId, tripId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viagem do estudante criada com sucesso!')),
            );
            return;  // Sai da função quando o ID é encontrado
          }
        }
      } catch (e) {
        print('Erro ao buscar o student_trip_id: $e');
      }

      // Espera antes de tentar novamente
      await Future.delayed(retryDelay);
      retryCount++;
    }

    // Se não conseguir o student_trip_id após todas as tentativas, lança erro
    throw Exception('Erro: student_trip_id não foi gerado pela API após várias tentativas.');
  }

  // Função para abrir o overlay de seleção de viagem
  void _toggleBusOverlay() {
    setState(() {
      _showBusOverlay = !_showBusOverlay;
      if (_showBusOverlay) {
        _fetchActiveBuses();
      }
    });
  }

  // Função para abrir o overlay de seleção de ponto de ônibus
  void _toggleBusStopOverlay(int tripId) {
    setState(() {
      _showBusStopOverlay = !_showBusStopOverlay;
      if (_showBusStopOverlay) {
        _fetchBusStops(tripId); // Busca os pontos de ônibus para a viagem selecionada
        _selectedTripId = tripId; // Armazena o tripId selecionado
      }
    });
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
                  'Você não está em nenhuma viagem atualmente.',
                  style: TextStyle(
                    color: Color(0xFF000000).withOpacity(0.70),
                    fontSize: getHeightProportion(context, 16),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(getHeightProportion(context, 16.0)),
              child: ButtonThree(
                buttonText: 'Selecionar viagem',
                backgroundColor: Color(0xFF395BC7),
                onPressed: _toggleBusOverlay,
              ),
            ),
          ),
          if (_showBusOverlay)
            BuildOverlay(
              title: 'Selecione sua viagem',
              content: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildBusList(), // Exibe a lista de ônibus ativos
              onCancel: _toggleBusOverlay,
            ),
          if (_showBusStopOverlay)
            BuildOverlay(
              title: 'Selecione seu ponto de ônibus',
              content: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildBusStopList(), // Exibe a lista de pontos de ônibus
              onCancel: () => _toggleBusStopOverlay(0), // Fecha o overlay de pontos de ônibus
            ),
        ],
      ),
    );
  }

  // Função para construir a lista de viagens ativas
  Widget _buildBusList() {
    return ListView.builder(
      itemCount: _busList.length,
      itemBuilder: (context, index) {
        final bus = _busList[index];
        return Padding(
          padding: EdgeInsets.only(bottom: getHeightProportion(context, 20)),
          child: BusDetailsButton(
            onPressed: () {
              // Aqui, ao selecionar a viagem, abre o overlay para selecionar o ponto de ônibus
              _toggleBusStopOverlay(bus['tripId']);
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
    if (isCreatingTrip) {
      // Mostra o indicador de carregamento enquanto a viagem está sendo criada
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _busStopList.length,
      itemBuilder: (context, index) {
        final busStop = _busStopList[index];
        final busStopId = busStop['id'];

        return Padding(
          padding: EdgeInsets.only(bottom: getHeightProportion(context, 20)),
          child: TripBusStop(
            onPressed: () {
              if (busStopId != null) {
                print("Selecionado ponto de ônibus: ${busStop['name']}");
                _createStudentTrip(_selectedTripId, int.parse(busStopId)); // Cria a viagem
              } else {
                print('Erro: ID do ponto de ônibus é nulo');
              }
            },
            busStopName: busStop['name']!,
            busStopStatus: busStop['status']!,
          ),
        );
      },
    );
  }
}
