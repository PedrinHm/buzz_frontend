import 'package:buzz/controllers/trip_controller.dart';
import 'package:buzz/screens/Driver/bus_stop_inactive_screen.dart';
import 'package:buzz/screens/Driver/student_bus_stop_active_screen.dart';
import 'package:buzz/services/decodeJsonResponse.dart';
import 'package:buzz/widgets/Geral/buildOverlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:buzz/widgets/Geral/Custom_Pop_up.dart';
import 'package:buzz/utils/size_config.dart';
import 'package:buzz/config/config.dart';
import 'package:buzz/utils/error_handling.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tripId = widget.tripId;
    _isReturnTrip = widget.isReturnTrip;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await fetchBusStops();
      setState(() {
        tripBusStops = data;
        tripBusStops.sort(_compareBusStopStatus);
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelTrip() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    var url = Uri.parse('${Config.backendUrl}/trips/${_tripId ?? ''}/cancel');

    try {
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Viagem cancelada com sucesso.'),
          backgroundColor: Colors.green,
        ));

        setState(() {
          _tripId = null;
          _isReturnTrip = false;
        });

        Provider.of<TripController>(context, listen: false).endTrip();
      } else {
        throw Exception('Erro ao cancelar a viagem');
      }
    } catch (e) {
      print("Erro ao cancelar a viagem: $e");
      showErrorMessage(context, e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> toggleBusIssue() async {
    if (_isProcessing) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          message: _busIssue
              ? "Tem certeza de que deseja remover o problema do ônibus?"
              : "Tem certeza de que deseja reportar um problema no ônibus?",
          confirmText: "Sim",
          cancelText: "Não",
          onConfirm: () {
            Navigator.of(context).pop(); // Fecha o popup
            _reportOrRemoveBusIssue(); // Chama o método para reportar/remover o problema
          },
          onCancel: () {
            Navigator.of(context).pop(); // Apenas fecha o popup
          },
        );
      },
    );
  }

  Future<void> _reportOrRemoveBusIssue() async {
    setState(() {
      _isProcessing = true;
    });

    var url = Uri.parse('${Config.backendUrl}/trips/$_tripId/report_bus_issue');
    try {
      var response = await http.put(url);
      if (response.statusCode == 200) {
        var data = decodeJsonResponse(response);
        setState(() {
          _busIssue = data['bus_issue'];
        });
      } else {
        showErrorMessage(context, response.body);
      }
    } catch (e) {
      print('Erro ao reportar problema no ônibus: $e');
      showErrorMessage(context, e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<List<Map<String, String>>> fetchBusStops() async {
    var url = Uri.parse('${Config.backendUrl}/trips/$_tripId/bus_stops');
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
        '${Config.backendUrl}/trip_bus_stops/stops_on_the_way/$_tripId');
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
    String successMessage;

    if (action == 'Encerrar viagem de ida') {
      endpoint = 'trip_bus_stops/finalize_current_stop/$_tripId';
      successMessage = 'Ponto atual finalizado com sucesso.';
    } else if (action == 'Encerrar viagem de volta') {
      endpoint = 'trips/${_tripId ?? ''}/finalize_return_trip';
      successMessage = 'Viagem de volta finalizada com sucesso!';
    } else if (action == 'Finalizar viagem') {
      endpoint = 'trips/${_tripId ?? ''}/finalize_outbound_trip';
      successMessage = 'Viagem de ida finalizada com sucesso! Iniciando viagem de volta.';
    } else {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    var url = Uri.parse('${Config.backendUrl}/$endpoint');

    try {
      var response = await http.put(url);

      if (response.statusCode == 200) {
        final responseData = decodeJsonResponse(response);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ));

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
        // Caso o status da resposta seja diferente de 200, lançar erro
        throw Exception('Erro ao finalizar a viagem: ${response.body}');
      }
    } catch (e) {
      print("Erro durante a finalização da viagem: $e");
      showErrorMessage(context, e.toString());
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
        '${Config.backendUrl}/trip_bus_stops/select_next_stop/$_tripId?new_stop_id=$stopId');
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
        showErrorMessage(context, response.body);
      }
    } catch (e) {
      print('Erro ao definir o próximo ponto: $e');
      showErrorMessage(context, e.toString());
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
        '${Config.backendUrl}/trip_bus_stops/update_next_bus_stop/$_tripId');
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
        showErrorMessage(context, response.body);
      }
    } catch (e) {
      print('Erro ao atualizar o status: $e');
      showErrorMessage(context, e.toString());
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
            _cancelTrip();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showConfirmFinalizeReturnTripPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          message: "Tem certeza de que deseja finalizar a viagem de volta?",
          confirmText: "Sim",
          cancelText: "Não",
          onConfirm: () {
            Navigator.of(context).pop();
            _finalizeTrip('Encerrar viagem de volta');
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
          return SafeArea(
            // Garante que o overlay respeite as áreas seguras, como a barra de navegação
            top:
                false, // Permite que o overlay cubra a parte superior se necessário
            bottom: true, // Protege a barra de navegação
            child: Align(
              alignment: Alignment
                  .bottomCenter, // Alinha o overlay na parte inferior da tela
              child: BuildOverlay(
                title: 'Selecione o Próximo Ponto',
                content: ListView.builder(
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return Material(
                      color: Colors
                          .transparent, // Mantém o fundo transparente para combinar com o design
                      child: TripBusStop(
                        busStopName: stop['name']!,
                        busStopStatus: 'A caminho',
                        onPressed: () {
                          _selectNextStop(int.parse(stop['id']!));
                          Navigator.of(context)
                              .pop(); // Fecha o overlay após seleção
                        },
                      ),
                    );
                  },
                ),
                onCancel: () =>
                    Navigator.of(context).pop(), // Fecha o overlay ao cancelar
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                        height:
                            getHeightProportion(context, 40)), // Proporção ajustada
                    CustomTitleWidget(title: 'Pontos de Ônibus'),
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
      buttonText = _isReturnTrip ? 'Encerrar viagem de volta' : 'Encerrar viagem de ida';
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
                    backgroundColor:
                        _busIssue ? Colors.grey : Color(0xFF3E9B4F),
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
                              } else if (buttonText ==
                                  'Encerrar viagem de volta') {
                                _showConfirmFinalizeReturnTripPopup();
                              } else if (buttonText ==
                                  'Encerrar viagem de ida') {
                                _showConfirmFinalizeTripPopup();
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
            padding: EdgeInsets.all(getHeightProportion(context, 8.0)),
            child: Center(
              child: ButtonThree(
                buttonText: 'Finalizar viagem',
                backgroundColor: Colors.red,
                onPressed: _isProcessing
                    ? () {}
                    : () => _finalizeTrip(_isReturnTrip ? 'Encerrar viagem de volta' : 'Finalizar viagem'),
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
                    : () => _showConfirmFinalizeReturnTripPopup(),
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
