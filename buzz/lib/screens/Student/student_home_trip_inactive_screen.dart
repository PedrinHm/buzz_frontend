import 'package:buzz/widgets/Geral/Bus_Stop_Selection_Overlay.dart';
import 'package:flutter/material.dart';
import 'package:buzz/widgets/Geral/Bus_Selection_Dialog.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // Importa o provider
import '../../controllers/trip_controller.dart'; // Importa o controlador de viagens

class StudentHomeTripInactiveScreen extends StatefulWidget {
  final int studentId; // Adiciona o parâmetro para receber o ID do estudante

  StudentHomeTripInactiveScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentHomeTripInactiveScreenState createState() => _StudentHomeTripInactiveScreenState();
}

class _StudentHomeTripInactiveScreenState extends State<StudentHomeTripInactiveScreen> {
  bool _showBusStopOverlay = false;
  List<Map<String, dynamic>> _busStops = [];
  int _selectedTripId = 0;  // Armazena o ID da viagem selecionada
  int _selectedBusStopId = 0;  // Armazena o ID do ponto de ônibus selecionado

void _handleBusSelection(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BusSelectionDialog(
        onBusSelected: (int selectedBusId, int selectedTripId, int selectedTripType) {
          Navigator.pop(context); // Fechar o diálogo após a seleção
          print('Ônibus selecionado: $selectedBusId, Viagem: $selectedTripId, Tipo de viagem: $selectedTripType'); // Debug print
          _selectedTripId = selectedTripId; // Armazena o tripId selecionado
          _fetchBusStops(widget.studentId); // Passa o ID do estudante para buscar os pontos de ônibus
        },
        url: 'http://127.0.0.1:8000/buses/trips/active_trips',
      );
    },
  );
}

void _fetchBusStops(int studentId) async {
  // Utiliza o novo endpoint com o ID do estudante e da viagem
  String url = 'http://127.0.0.1:8000/bus_stops/action/trip?student_id=$studentId&trip_id=$_selectedTripId';

  print('Fetching bus stops from URL: $url'); // Debug print

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    print('Dados recebidos dos pontos de ônibus: $responseData'); // Debug print

    setState(() {
      _busStops = List<Map<String, dynamic>>.from(responseData);
      _showBusStopSelectionOverlay();
    });
  } else {
    print('Erro ao buscar pontos de ônibus: ${response.reasonPhrase}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao buscar pontos de ônibus')),
    );
  }
}

  void _showBusStopSelectionOverlay() {
    setState(() {
      _showBusStopOverlay = true;
    });
  }

  void _hideBusStopSelectionOverlay() {
    setState(() {
      _showBusStopOverlay = false;
    });
  }

  void _handleBusStopSelected(String busStopName, int busStopId) { 
    print('Ponto de ônibus selecionado: $busStopName');
    _selectedBusStopId = busStopId;  
    _hideBusStopSelectionOverlay(); 
    _createStudentTrip();  
  }

  Future<void> _createStudentTrip() async {
    final url = 'http://127.0.0.1:8000/student_trips';
    final body = json.encode({
      'trip_id': _selectedTripId,
      'student_id': widget.studentId,  // Usa o 'studentId' passado para o widget
      'point_id': _selectedBusStopId,  
    });

    print('Criando viagem do estudante com dados: $body'); 

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      print('Viagem do estudante criada com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Viagem do estudante criada com sucesso!')),
      );
      
      // Informa ao controlador que uma viagem foi iniciada
      final tripController = Provider.of<TripController>(context, listen: false);
      tripController.startTrip(_selectedTripId, 1);  // 1 representa a viagem de "ida"

    } else {
      print('Erro ao criar viagem do estudante: ${response.reasonPhrase}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar viagem do estudante')),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Você não está em nenhuma viagem atualmente.',
                  style: TextStyle(
                    color: Color(0xFF000000).withOpacity(0.70),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ButtonThree(
                buttonText: 'Selecionar viagem',
                backgroundColor: Color(0xFF395BC7),
                onPressed: () => _handleBusSelection(context),
              ),
            ),
          ),
          if (_showBusStopOverlay) 
            BusStopSelectionOverlay(
              onCancel: _hideBusStopSelectionOverlay,
              onBusStopSelected: (String busStopName) {
                _handleBusStopSelected(
                  busStopName,
                  int.parse(_busStops.firstWhere((busStop) => busStop['name'] == busStopName)['id'].toString()), 
                );
              },
              busStops: _busStops, 
            ),
        ],
      ),
    );
  }
}
