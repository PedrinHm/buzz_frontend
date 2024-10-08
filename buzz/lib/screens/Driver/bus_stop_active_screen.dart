import 'package:buzz/controllers/trip_controller.dart';
import 'package:buzz/screens/Driver/bus_stop_inactive_screen.dart';
import 'package:buzz/screens/Driver/student_bus_stop_active_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:buzz/widgets/Geral/Custom_Pop_up.dart';
import 'package:buzz/utils/size_config.dart'; // Importar funções de tamanho

class BusStopActiveScreen extends StatefulWidget {
  final VoidCallback endTrip;
  final int tripId;
  final bool isReturnTrip;

  BusStopActiveScreen({
    required this.endTrip,
    required this.tripId,
    required this.isReturnTrip,
  });

  @override
  _BusStopActiveScreenState createState() => _BusStopActiveScreenState();
}

class _BusStopActiveScreenState extends State<BusStopActiveScreen> {
  late int? _tripId; // Permitir que _tripId seja nulo
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

    var url = Uri.parse(
        'https://buzzbackend-production.up.railway.app/trips/$_tripId/report_bus_issue');
    try {
      var response = await http.put(url);
      if (response.statusCode == 200) {
        var data = decodeJsonResponse(response);
        setState(() {
          _busIssue = data['bus_issue'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Erro ao reportar problema no ônibus: ${response.body}'),
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
    var url = Uri.parse(
        'https://buzzbackend-production.up.railway.app/trips/$_tripId/bus_stops');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = decodeJsonResponse(response);
      setState(() {
        _busIssue = data['bus_issue'] ?? false;
      });

      return (data['bus_stops'] as List<dynamic>).map((item) {
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
    var url = Uri.parse(
        'https://buzzbackend-production.up.railway.app/trip_bus_stops/pontos_a_caminho/$_tripId');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = decodeJsonResponse(response);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'name': item['name'] as String,
              })
          .toList();
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
    return tripBusStops.where((stop) => stop['status'] == 'No ponto').length ==
            1 &&
        tripBusStops.where((stop) => stop['status'] == 'Já passou').length ==
            tripBusStops.length - 1;
  }

  Future<void> _finalizeTrip(String action) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    print("Iniciando processo de encerramento da viagem.");
    print(
        "tripId atual: $_tripId, activeTripId atual: ${Provider.of<TripController>(context, listen: false).activeTripId}");

    String endpoint;

    if (action == 'Encerrar viagem de ida') {
      endpoint = 'trip_bus_stops/finalizar_ponto_atual/$_tripId';
    } else if (action == 'Encerrar viagem de volta') {
      endpoint = 'trips/${_tripId ?? ''}/finalizar_volta';
    } else if (action == 'Finalizar viagem') {
      endpoint = 'trips/${_tripId ?? ''}/finalizar_ida';
    } else {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    var url =
        Uri.parse('https://buzzbackend-production.up.railway.app/$endpoint');

    try {
      var response = await http.put(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (action == 'Finalizar viagem') {
          // Se for uma viagem de ida, inicia a viagem de volta
          Future.microtask(() {
            setState(() {
              _tripId = responseData['new_trip_id'] ?? _tripId;
              _isReturnTrip = true;
            });
            print("Novo tripId para viagem de volta: $_tripId");
            // Recarrega a lista de pontos para a nova viagem de volta
            fetchBusStops().then((data) {
              setState(() {
                tripBusStops = data;
                tripBusStops.sort(_compareBusStopStatus);
              });
            });
          });
        } else if (action == 'Encerrar viagem de volta') {
          // Finaliza completamente a viagem de volta e redefine o estado para mostrar a tela inativa
          Future.microtask(() {
            setState(() {
              _tripId = null;
              _isReturnTrip = false;
              // Utilizando o TripController para redefinir o activeTripId
              Provider.of<TripController>(context, listen: false).endTrip();
              print("Viagem de volta finalizada.");
              print(
                  "tripId atual: $_tripId, activeTripId atual: ${Provider.of<TripController>(context, listen: false).activeTripId}");
            });
          });
        }
      } else {
        throw Exception('Erro ao finalizar a viagem');
      }
    } catch (e) {
      print("Erro durante a finalização da viagem: $e");
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

    var url = Uri.parse(
        'https://buzzbackend-production.up.railway.app/trip_bus_stops/selecionar_proximo_ponto/$_tripId?new_stop_id=$stopId');
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

    var url = Uri.parse(
        'https://buzzbackend-production.up.railway.app/trip_bus_stops/atualizar_proximo_para_no_ponto/$_tripId');
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
          content:
              Text('Erro ao atualizar o status do ponto: ${response.body}'),
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

  void _showConfirmFinalizeTripPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          message: "Tem certeza de que deseja finalizar a viagem de ida?",
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
              padding: EdgeInsets.all(
                  getHeightProportion(context, 16.0)), // Proporção ajustada
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...stops
                      .map((stop) => TripBusStop(
                            busStopName: stop['name']!,
                            busStopStatus: 'A caminho',
                            onPressed: () {
                              _selectNextStop(int.parse(stop['id']!));
                              Navigator.of(context).pop();
                            },
                          ))
                      .toList(),
                  SizedBox(
                      height: getHeightProportion(
                          context, 20)), // Proporção ajustada
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
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                  height:
                      getHeightProportion(context, 40)), // Proporção ajustada
              CustomTitleWidget(title: 'Viagem Atual - Pontos de Ônibus'),
              SizedBox(
                  height:
                      getHeightProportion(context, 20)), // Proporção ajustada
              Expanded(
                child: tripBusStops.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum ponto de ônibus encontrado.',
                          style: TextStyle(
                            color: Color(0xFF000000).withOpacity(0.70),
                            fontSize: getHeightProportion(
                                context, 16), // Proporção ajustada
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tripBusStops.length,
                        itemBuilder: (context, index) {
                          final stop = tripBusStops[index];
                          final status =
                              _busIssue && stop['status'] != 'Já passou'
                                  ? 'Ônibus com problema'
                                  : stop['status']!;
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: getHeightProportion(
                                    context, 10.0)), // Proporção ajustada
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
          // Exibir o fundo com a cor do tema e o indicador de carregamento quando uma requisição estiver em andamento
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Theme.of(context)
                    .scaffoldBackgroundColor, // Cor do fundo do tema
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReturnTripButtons() {
    String buttonText = 'Selecionar destino';

    if (tripBusStops.any((stop) => stop['status'] == 'Próximo ponto')) {
      buttonText = 'Estou no ponto';
    } else if (_isFinalStop()) {
      buttonText =
          _isReturnTrip ? 'Encerrar viagem de volta' : 'Encerrar viagem de ida';
    }

    return Column(
      children: [
        if (!_allStopsPassed()) // Exibir os botões apenas se não for o último ponto
          Padding(
            padding: EdgeInsets.all(
                getHeightProportion(context, 8.0)), // Proporção ajustada
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ButtonThree(
                    buttonText:
                        _busIssue ? 'Remover Problema' : 'Ônibus com problema',
                    backgroundColor: Color(0xFFCBB427),
                    onPressed: _isProcessing ? () {} : toggleBusIssue,
                  ),
                ),
                SizedBox(
                    width:
                        getWidthProportion(context, 10)), // Proporção ajustada
                Expanded(
                  child: ButtonThree(
                    buttonText: buttonText,
                    backgroundColor: _busIssue
                        ? Colors.grey
                        : Color(
                            0xFF3E9B4F), // Define o botão como cinza se houver problema
                    onPressed: _isProcessing
                        ? () {}
                        : () {
                            if (_busIssue) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'Resolva o problema do ônibus para partir.'),
                                backgroundColor: Colors.redAccent,
                              ));
                            } else {
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
        if (_allStopsPassed() &&
            tripBusStops.isNotEmpty) // Mostrar o botão de encerrar viagem
          Padding(
            padding: EdgeInsets.all(
                getHeightProportion(context, 8.0)), // Proporção ajustada
            child: Center(
              child: ButtonThree(
                buttonText: 'Finalizar viagem',
                backgroundColor: Colors.red,
                onPressed: _isProcessing
                    ? () {}
                    : () => _finalizeTrip('Finalizar viagem'),
              ),
            ),
          ),
        if (_isReturnTrip &&
            tripBusStops
                .isEmpty) // Exibir o botão "Finalizar viagem" se não houver pontos de ônibus na lista
          Padding(
            padding: EdgeInsets.all(
                getHeightProportion(context, 8.0)), // Proporção ajustada
            child: Center(
              child: ButtonThree(
                buttonText: 'Encerrar viagem',
                backgroundColor: Colors.red,
                onPressed: _isProcessing
                    ? () {}
                    : () => _finalizeTrip('Encerrar viagem de volta'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDepartureTripButtons() {
    return Padding(
      padding: EdgeInsets.all(
          getHeightProportion(context, 8.0)), // Proporção ajustada
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
          SizedBox(
              width: getWidthProportion(context, 10)), // Proporção ajustada
          Expanded(
            child: ButtonThree(
              buttonText: 'Finalizar Viagem',
              backgroundColor: Colors.red,
              onPressed: _isProcessing
                  ? () {}
                  : _showConfirmFinalizeTripPopup, // Chama o popup em vez de chamar a requisição direta
            ),
          ),
        ],
      ),
    );
  }
}
