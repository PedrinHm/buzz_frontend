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
        tripBusStops.sort((a, b) => _compareBusStopStatus(a['status']!, b['status']!));
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

  // Função de comparação para ordenar os pontos de ônibus
  int _compareBusStopStatus(String statusA, String statusB) {
    const statusOrder = {
      'No ponto': 2,
      'Próximo ponto': 3,
      'A caminho': 1,
      'Já passou': 4,
      'Desembarque': 6,
      'Ônibus com problema': 5,
    };

    return statusOrder[statusA]?.compareTo(statusOrder[statusB] ?? 0) ?? 0;
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
          // Se for uma viagem de ida, começamos automaticamente a viagem de volta
          final returnTripData = decodeJsonResponse(response);
          setState(() {
            tripBusStops = []; // Limpa a lista de paradas para a nova viagem
            _tripId = returnTripData['id']; // Define o novo ID da viagem
            _isReturnTrip = true; // Define que agora é uma viagem de volta
          });
          // Recarrega os pontos de ônibus para a nova viagem
          fetchBusStops().then((data) {
            setState(() {
              tripBusStops = data; // Carrega os novos pontos de ônibus
              tripBusStops.sort((a, b) => _compareBusStopStatus(a['status']!, b['status']!));
            });
          });
        } else {
          // Se for a viagem de volta, simplesmente finaliza a viagem
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

  void _showCancelTripPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          message: "Tem certeza de que deseja cancelar a viagem?",
          confirmText: "Sim",
          cancelText: "Não",
          onConfirm: () {
            Navigator.of(context).pop(); // Fechar o popup
            print('Cancelar Viagem Confirmado');
            // Implementar a lógica para cancelar a viagem aqui
          },
          onCancel: () {
            Navigator.of(context).pop(); // Fechar o popup
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
            Navigator.of(context).pop(); // Fechar o popup
            _finalizeTrip(); // Confirmar finalização da viagem
          },
          onCancel: () {
            Navigator.of(context).pop(); // Fechar o popup
          },
        );
      },
    );
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
                  buttonText: 'Selecionar destino',
                  backgroundColor: Color(0xFF3E9B4F),
                  onPressed: () {
                    print('Selecionar ponto de ônibus Pressionado');
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
                onPressed: _showFinalizeTripPopup, // Mostra o popup de confirmação
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
              onPressed: _showCancelTripPopup, // Mostra o popup de confirmação
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ButtonThree(
              buttonText: 'Finalizar Viagem',
              backgroundColor: Colors.red,
              onPressed: _showFinalizeTripPopup, // Mostra o popup de confirmação
            ),
          ),
        ],
      ),
    );
  }
}
