import 'package:buzz/utils/size_config.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/buildOverlay.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';

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
  List<Map<String, dynamic>> _busList = [];
  List<Map<String, dynamic>> _busStopList = [];
  int _selectedTripId = 0; // Armazena o tripId selecionado
  int _selectedBusStopId = 0; // Armazena o busStopId selecionado

  // Função para buscar as viagens ativas
  Future<void> _fetchActiveBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/buses/trips/active_trips'));

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

  // Função para criar a viagem do estudante
  Future<void> _createStudentTrip() async {
    final url = 'https://buzzbackend-production.up.railway.app/student_trips/';
    final body = json.encode({
      'trip_id': _selectedTripId,
      'student_id': widget.studentId,
      'point_id': _selectedBusStopId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Viagem do estudante criada com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viagem criada com sucesso!')),
        );
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
    }
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

  // Função para construir a lista de pontos de ônibus
  Widget _buildBusStopList() {
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
                _selectedBusStopId = int.parse(busStopId); // Armazena o ponto de ônibus selecionado
                _createStudentTrip(); // Cria a viagem do estudante
              } else {
                print('Erro: ID do ponto de ônibus é nulo');
              }
              _toggleBusStopOverlay(0); // Fecha o overlay após a seleção
            },
            busStopName: busStop['name']!,
            busStopStatus: busStop['status']!,
          ),
        );
      },
    );
  }
}
