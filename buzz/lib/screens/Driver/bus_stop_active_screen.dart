import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:buzz/widgets/Geral/Custom_Pop_up.dart';

// Função utilitária para decodificar as respostas HTTP
dynamic decodeJsonResponse(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    return json.decode(responseBody);
  } else {
    throw Exception('Failed to parse JSON, status code: ${response.statusCode}');
  }
}

class BusStopActiveScreen extends StatefulWidget {
  final VoidCallback endTrip;
  final int tripId;
  final bool isReturnTrip;

  BusStopActiveScreen({required this.endTrip, required this.tripId, required this.isReturnTrip});

  @override
  _BusStopActiveScreenState createState() => _BusStopActiveScreenState();
}

class _BusStopActiveScreenState extends State<BusStopActiveScreen> {
  late int _tripId;
  late bool _isReturnTrip;
  List<Map<String, String>> tripBusStops = [];

  @override
  void initState() {
    super.initState();
    _tripId = widget.tripId;
    _isReturnTrip = widget.isReturnTrip;
    fetchBusStops().then((data) {
      setState(() {
        tripBusStops = data;
        // Ordenar os pontos de ônibus após carregar os dados
        tripBusStops.sort(_compareBusStopStatus);
      });
    });
  }

  Future<List<Map<String, String>>> fetchBusStops() async {
    var url = Uri.parse('http://127.0.0.1:8000/trips/$_tripId/bus_stops');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = decodeJsonResponse(response);
      return data.map((item) => {
        'name': item['name'] as String,
        'status': item['status'] as String,
      }).toList().cast<Map<String, String>>();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load bus stop details');
    }
  }

Future<List<Map<String, String>>> fetchStopsOnTheWay() async {
    var url = Uri.parse('http://127.0.0.1:8000/trip_bus_stops/pontos_a_caminho/$_tripId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = decodeJsonResponse(response);
      return data.map<Map<String, String>>((item) => {
        'id': item['id'].toString(),
        'name': item['name'] as String,
      }).toList();
    } else {
      throw Exception('Failed to load stops on the way');
    }
}

  // Função de comparação para ordenar os pontos de ônibus
  int _compareBusStopStatus(Map<String, String> a, Map<String, String> b) {
    const statusOrder = {
      'A caminho': 1,
      'No ponto': 2,
      'Próximo ponto': 3,
      'Já passou': 4,
      'Ônibus com problema': 5,
      'Desembarque': 6,
    };

    int statusA = statusOrder[a['status']] ?? 0;
    int statusB = statusOrder[b['status']] ?? 0;

    return statusA.compareTo(statusB);
  }

  bool _allStopsPassed() {
    return tripBusStops.every((stop) => stop['status'] == 'Já passou');
  }

  Future<void> _finalizeTrip() async {
    String endpoint = _isReturnTrip ? 'finalizar_volta' : 'finalizar_ida';
    var url = Uri.parse('http://127.0.0.1:8000/trips/$_tripId/$endpoint');

    try {
      var response = await http.put(url);
      if (response.statusCode == 200) {
        if (!_isReturnTrip) {
          final returnTripData = decodeJsonResponse(response);
          setState(() {
            tripBusStops = [];
            _tripId = returnTripData['id'];
            _isReturnTrip = true;
          });
          fetchBusStops().then((data) {
            setState(() {
              tripBusStops = data;
              tripBusStops.sort(_compareBusStopStatus);
            });
          });
        } else {
          widget.endTrip();
        }
      } else {
        throw Exception('Failed to finalize the trip');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erro ao finalizar a viagem: $e"),
      ));
    }
  }

  Future<void> _selectNextStop(int stopId) async {
    var url = Uri.parse('http://127.0.0.1:8000/trip_bus_stops/selecionar_proximo_ponto/$_tripId?new_stop_id=$stopId');
    var response = await http.put(url);

    if (response.statusCode == 200) {
      print('Próximo ponto definido com sucesso');
      fetchBusStops().then((data) {
        setState(() {
          tripBusStops = data;
          tripBusStops.sort(_compareBusStopStatus);
        });
      });
    } else {
      print('Erro ao definir o próximo ponto: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao definir o próximo ponto: ${response.body}'),
      ));
    }
  }

  Future<void> _updateNextToAtStop() async {
    var url = Uri.parse('http://127.0.0.1:8000/trip_bus_stops/atualizar_proximo_para_no_ponto/$_tripId');
    var response = await http.put(url);

    if (response.statusCode == 200) {
      print('Status atualizado para No ponto');
      // Recarregar os pontos de ônibus para refletir a mudança
      fetchBusStops().then((data) {
        setState(() {
          tripBusStops = data;
          tripBusStops.sort(_compareBusStopStatus);
        });
      });
    } else {
      print('Erro ao atualizar o status: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao atualizar o status do ponto: ${response.body}'),
      ));
    }
  }

  void _showCancelTripPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          message: "Tem certeza de que deseja cancelar a viagem?",
          confirmText: "Sim",
          cancelText: "Não",
          onConfirm: () {
            Navigator.of(context).pop();
            print('Cancelar Viagem Confirmado');
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showFinalizeTripPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          message: "Tem certeza de que deseja finalizar a viagem?",
          confirmText: "Sim",
          cancelText: "Não",
          onConfirm: () {
            Navigator.of(context).pop();
            _finalizeTrip();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showSelectNextStopPopup() {
    fetchStopsOnTheWay().then((stops) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black.withOpacity(0.7),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...stops.map((stop) => TripBusStop(
                    busStopName: stop['name']!,
                    busStopStatus: 'A caminho',
                    onPressed: () {
                      _selectNextStop(int.parse(stop['id']!));
                      Navigator.of(context).pop();
                    },
                  )).toList(),
                  SizedBox(height: 20),
                  ButtonThree(
                    buttonText: 'Cancelar',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          CustomTitleWidget(title: 'Viagem Atual - Pontos de Ônibus'),
          SizedBox(height: 20),
          Expanded(
            child: tripBusStops.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum ponto de ônibus encontrado.',
                      style: TextStyle(
                        color: Color(0xFF000000).withOpacity(0.70),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tripBusStops.length,
                    itemBuilder: (context, index) {
                      final stop = tripBusStops[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TripBusStop(
                          onPressed: () {
                            // Add action for each bus stop
                          },
                          busStopName: stop['name']!,
                          busStopStatus: stop['status']!,
                        ),
                      );
                    },
                  ),
          ),
          if (_isReturnTrip)
            _buildReturnTripButtons()
          else
            _buildDepartureTripButtons(),
        ],
      ),
    );
  }

  Widget _buildReturnTripButtons() {
    String buttonText = 'Selecionar destino';

    if (tripBusStops.any((stop) => stop['status'] == 'Próximo ponto')) {
      buttonText = 'Estou no ponto';
    }

    return Column(
      children: [
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
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ButtonThree(
                  buttonText: buttonText,
                  backgroundColor: Color(0xFF3E9B4F),
                  onPressed: () {
                    if (buttonText == 'Estou no ponto') {
                      _updateNextToAtStop();
                    } else {
                      _showSelectNextStopPopup();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (_allStopsPassed() && tripBusStops.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ButtonThree(
                buttonText: 'Encerrar Viagem',
                backgroundColor: Colors.red,
                onPressed: _showFinalizeTripPopup,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDepartureTripButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ButtonThree(
              buttonText: 'Cancelar Viagem',
              backgroundColor: Colors.grey,
              onPressed: _showCancelTripPopup,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ButtonThree(
              buttonText: 'Finalizar Viagem',
              backgroundColor: Colors.red,
              onPressed: _showFinalizeTripPopup,
            ),
          ),
        ],
      ),
    );
  }
}
