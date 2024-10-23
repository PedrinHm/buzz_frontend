import 'package:buzz/controllers/trip_controller.dart';
import 'package:buzz/screens/Admin/form_screen.dart';
import 'package:buzz/utils/size_config.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Custom_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/buildOverlay.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:provider/provider.dart';
import 'package:buzz/config/config.dart';

class StudentHomeTripInactiveScreen extends StatefulWidget {
  final int studentId;

  StudentHomeTripInactiveScreen({Key? key, required this.studentId})
      : super(key: key);

  @override
  _StudentHomeTripInactiveScreenState createState() =>
      _StudentHomeTripInactiveScreenState();
}

class _StudentHomeTripInactiveScreenState
    extends State<StudentHomeTripInactiveScreen> {
  bool _showBusOverlay = false;
  bool _showBusStopOverlay = false;
  bool isLoading = false;
  bool isCreatingTrip = false;
  List<Map<String, dynamic>> _busList = [];
  List<Map<String, dynamic>> _busStopList = [];
  int _selectedTripId = 0; // Armazena o tripId selecionado
  int _selectedBusStopId = 0; // Armazena o busStopId selecionado

  Future<void> _fetchActiveBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('${Config.backendUrl}/buses/active_trips/'));

      if (response.statusCode == 200) {
        List<dynamic> data =
            decodeJsonResponse(response); 

        setState(() {
          _busList = data
              .map((item) => {
                    'busId': item['bus_id'],
                    'tripId': item['trip_id'],
                    'registrationNumber': item['registration_number'],
                    'name': item['name'],
                    'capacity': item['capacity'],
                    'tripType': item['trip_type'],
                    'availableSeats':
                        item['available_seats'], // Inclui as vagas disponíveis
                  })
              .toList();
        });
      } else {
        // Decodifica a resposta de erro e exibe o detalhe
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail = errorData['detail'] ?? 'Erro ao carregar ônibus disponíveis';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching active buses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar viagens ativas'),
         backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBusStops(int tripId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          '${Config.backendUrl}/bus_stops/action/trip?student_id=${widget.studentId}&trip_id=$tripId'));

      if (response.statusCode == 200) {
        List<dynamic> data =
            decodeJsonResponse(response); // Usando a função utf8

        setState(() {
          _busStopList = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'name': item['name'],
                    'status': item['status'],
                  })
              .toList();
        });
      } else {
        // Decodifica a resposta de erro e exibe o detalhe
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail = errorData['detail'] ?? 'Erro ao carregar pontos de ônibus';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar pontos de ônibus'),
         backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createStudentTrip(int tripId, int pointId) async {
    setState(() {
      isCreatingTrip = true;
    });

    final url = '${Config.backendUrl}/student_trips/';

    final body = json.encode({
      'trip_id': tripId,
      'student_id': widget.studentId,
      'point_id': pointId,
    });
    print(
        'trip_id: $tripId, student_id: ${widget.studentId}, point_id: $pointId');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        await _waitForStudentTripId(widget.studentId, tripId);
      } else if (response.statusCode == 400 &&
          response.body.contains("Capacidade do onibus atingida")) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return CustomPopup(
              message: 'O ônibus está cheio. Deseja entrar na fila de espera?',
              confirmText: 'Sim',
              cancelText: 'Não',
              onConfirm: () {
                Navigator.of(dialogContext).pop();
                _createStudentTripWaitlist(tripId, pointId);
              },
              onCancel: () {
                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
      } else {
        // Decodifica a resposta de erro e exibe o detalhe
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail = errorData['detail'] ?? 'Erro ao criar viagem do estudante';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao criar viagem: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar viagem do estudante'),
         backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isCreatingTrip = false;
      });
    }
  }

  Future<void> _createStudentTripWaitlist(int tripId, int pointId) async {
    setState(() {
      isCreatingTrip = true;
    });

    final url = '${Config.backendUrl}/student_trips/?waitlist=true';
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
        await _waitForStudentTripId(widget.studentId, tripId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você entrou na fila de espera com sucesso!'),
           backgroundColor: Colors.green,
          ),
        );
      } else {
        // Decodifica a resposta de erro e exibe o detalhe
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail = errorData['detail'] ?? 'Erro ao entrar na fila de espera';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao entrar na fila de espera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar na fila de espera'),
         backgroundColor: Colors.red,),
      );
    } finally {
      setState(() {
        isCreatingTrip = false;
      });
    }
  }

  Future<void> _waitForStudentTripId(int studentId, int tripId) async {
    int retryCount = 0;
    const int maxRetries = 10;
    const Duration retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
            Uri.parse('${Config.backendUrl}/student_trips/active/$studentId'));

        if (response.statusCode == 200) {
          final tripData = decodeJsonResponse(response);
          final studentTripId = tripData['student_trip_id'];

          if (studentTripId != null) {
            final tripController =
                Provider.of<TripController>(context, listen: false);
            tripController.startStudentTrip(studentTripId, tripId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Viagem do estudante criada com sucesso!'),
                   backgroundColor: Colors.green,
              ),
            );
            return;
          }
        } else {
          // Decodifica a resposta de erro e exibe o detalhe
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          final errorDetail = errorData['detail'] ?? 'Erro ao buscar o student_trip_id';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorDetail),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Erro ao buscar o student_trip_id: $e');
      }

      await Future.delayed(retryDelay);
      retryCount++;
    }

    throw Exception(
        'Erro: student_trip_id não foi gerado pela API após várias tentativas.');
  }

  void _toggleBusOverlay() {
    setState(() {
      _showBusOverlay = !_showBusOverlay;
      if (_showBusOverlay) {
        _fetchActiveBuses();
      }
    });
  }

  void _toggleBusStopOverlay(int tripId) {
    setState(() {
      _showBusStopOverlay = !_showBusStopOverlay;
      if (_showBusStopOverlay) {
        _fetchBusStops(tripId);
        _selectedTripId = tripId;
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
                  : _buildBusList(),
              onCancel: _toggleBusOverlay,
            ),
          if (_showBusStopOverlay)
            BuildOverlay(
              title: 'Selecione seu ponto de ônibus',
              content: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildBusStopList(),
              onCancel: () => _toggleBusStopOverlay(0),
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
        final int availableSeats = bus['availableSeats'];

        // Definir a cor do botão com base no número de vagas disponíveis
        final Color buttonColor = availableSeats == 0
            ? Color(0xFFFFBA18) // Amarelo se não houver vagas
            : Color(0xFF395BC7); // Azul padrão se houver vagas

        return Padding(
          padding: EdgeInsets.only(bottom: getHeightProportion(context, 20)),
          child: BusDetailsButton(
            onPressed: () {
              _toggleBusStopOverlay(bus['tripId']);
              _toggleBusOverlay();
            },
            busNumber: bus['registrationNumber'],
            driverName: bus['name'],
            capacity: bus['capacity'],
            availableSeats:
                availableSeats, // Passando availableSeats corretamente
            color: buttonColor, // Aplicando a cor condicional
          ),
        );
      },
    );
  }

  Widget _buildBusStopList() {
    if (isCreatingTrip) {
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
                _createStudentTrip(_selectedTripId, int.parse(busStopId));
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
