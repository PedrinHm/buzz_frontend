import 'package:buzz/screens/Driver/student_bus_stop_active_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:buzz/widgets/Geral/Custom_Pop_up.dart';

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
  bool _isProcessing = false;
  bool _busIssue = false;

  @override
  void initState() {
    super.initState();
    _tripId = widget.tripId;
    _isReturnTrip = widget.isReturnTrip;
    fetchBusStops().then((data) {
      setState(() {
        tripBusStops = data;
        tripBusStops.sort(_compareBusStopStatus);
      });
    });
  }

    Future<void> toggleBusIssue() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    var url = Uri.parse('https://buzzbackend-production.up.railway.app/trips/$_tripId/report_bus_issue');
    try {
      var response = await http.put(url);
      if (response.statusCode == 200) {
        var data = decodeJsonResponse(response);
        setState(() {
          _busIssue = data['bus_issue'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao reportar problema no ônibus: ${response.body}'),
        ));
      }
    } catch (e) {
      print('Erro ao reportar problema no ônibus: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }


Future<List<Map<String, String>>> fetchBusStops() async {
  var url = Uri.parse('https://buzzbackend-production.up.railway.app/trips/$_tripId/bus_stops');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var data = decodeJsonResponse(response);
    setState(() {
      _busIssue = data['bus_issue'] ?? false;
    });

    return (data['bus_stops'] as List<dynamic>).map((item) {
      // Se o status for "Já passou", ele não será alterado para "Ônibus com problema"
      String status = item['status'] as String;
      if (_busIssue && status != 'Já passou') {
        status = 'Ônibus com problema';
      }
      return {
        'name': item['name'] as String,
        'status': status,
      };
    }).toList();
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception('Failed to load bus stop details');
  }
}



  Future<List<Map<String, String>>> fetchStopsOnTheWay() async {
    var url = Uri.parse('https://buzzbackend-production.up.railway.app/trip_bus_stops/pontos_a_caminho/$_tripId');
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

  bool _isFinalStop() {
    return tripBusStops.where((stop) => stop['status'] == 'No ponto').length == 1 &&
           tripBusStops.where((stop) => stop['status'] == 'Já passou').length == tripBusStops.length - 1;
  }

  Future<void> _finalizeTrip(String action) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    String endpoint;

    if (action == 'Encerrar viagem de ida') {
      endpoint = 'trip_bus_stops/finalizar_ponto_atual/$_tripId';
    } else if (action == 'Encerrar viagem de volta') {
      endpoint = 'trips/$_tripId/finalizar_volta';
    } else if (action == 'Finalizar viagem') {
       endpoint = 'trips/$_tripId/finalizar_ida';
    } else {
      return;
    }

    var url = Uri.parse('https://buzzbackend-production.up.railway.app/$endpoint');

    try {
      var response = await http.put(url);
      if (response.statusCode == 200) {
        if (action == 'Encerrar viagem de ida') {
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
          fetchBusStops().then((data) {
            setState(() {
              tripBusStops = data;
              tripBusStops.sort(_compareBusStopStatus);
            });
          });
          if (_allStopsPassed()) {
            widget.endTrip();
          }
        }
      } else {
        throw Exception('Failed to finalize the trip');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erro ao finalizar a viagem: $e"),
      ));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _selectNextStop(int stopId) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    var url = Uri.parse('https://buzzbackend-production.up.railway.app/trip_bus_stops/selecionar_proximo_ponto/$_tripId?new_stop_id=$stopId');
    try {
      var response = await http.put(url);
      if (response.statusCode == 200) {
        fetchBusStops().then((data) {
          setState(() {
            tripBusStops = data;
            tripBusStops.sort(_compareBusStopStatus);
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao definir o próximo ponto: ${response.body}'),
        ));
      }
    } catch (e) {
      print('Erro ao definir o próximo ponto: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _updateNextToAtStop() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    var url = Uri.parse('https://buzzbackend-production.up.railway.app/trip_bus_stops/atualizar_proximo_para_no_ponto/$_tripId');
    try {
      var response = await http.put(url);
      if (response.statusCode == 200) {
        fetchBusStops().then((data) {
          setState(() {
            tripBusStops = data;
            tripBusStops.sort(_compareBusStopStatus);
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao atualizar o status do ponto: ${response.body}'),
        ));
      }
    } catch (e) {
      print('Erro ao atualizar o status: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
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
          message: "Tem certeza de que deseja finalizar o ponto atual?",
          confirmText: "Sim",
          cancelText: "Não",
          onConfirm: () {
            Navigator.of(context).pop();
            _finalizeTrip('Finalizar viagem');
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
                    final status = _busIssue && stop['status'] != 'Já passou' 
                        ? 'Ônibus com problema' 
                        : stop['status']!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TripBusStop(
                        onPressed: () {
                          // Ação para cada ponto de ônibus
                        },
                        busStopName: stop['name']!,
                        busStopStatus: status,
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
  } else if (_isFinalStop()) {
    buttonText = _isReturnTrip ? 'Encerrar viagem de volta' : 'Encerrar viagem de ida';
  }

  return Column(
    children: [
      if (!_allStopsPassed()) // Exibir os botões apenas se não for o último ponto
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ButtonThree(
                  buttonText: _busIssue ? 'Remover Problema' : 'Ônibus com problema',
                  backgroundColor: Color(0xFFCBB427),
                  onPressed: _isProcessing
                      ? () {}
                      : toggleBusIssue,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ButtonThree(
                  buttonText: buttonText,
                  backgroundColor: _busIssue ? Colors.grey : Color(0xFF3E9B4F), // Define o botão como cinza se houver problema
                  onPressed: _isProcessing
                      ? () {}
                      : () {
                          if (_busIssue) {
                            // Mostrar mensagem se houver problema com o ônibus
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Resolva o problema do ônibus para partir.'),
                              backgroundColor: Colors.redAccent,
                            ));
                          } else {
                            // Ação normal se não houver problema
                            if (buttonText == 'Estou no ponto') {
                              _updateNextToAtStop();
                            } else if (buttonText.contains('Encerrar')) {
                              _finalizeTrip(buttonText);
                            } else {
                              _showSelectNextStopPopup();
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      if (_allStopsPassed() && tripBusStops.isNotEmpty) // Mostrar o botão de encerrar viagem
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ButtonThree(
              buttonText: 'Finalizar viagem',
              backgroundColor: Colors.red,
              onPressed: _isProcessing ? () {} : () => _finalizeTrip('Finalizar viagem'),
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
              onPressed: _isProcessing ? () {} : _showCancelTripPopup,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ButtonThree(
              buttonText: 'Finalizar Viagem',
              backgroundColor: Colors.red,
              onPressed: _isProcessing ? () {} : _showFinalizeTripPopup,
            ),
          ),
        ],
      ),
    );
  }
}

