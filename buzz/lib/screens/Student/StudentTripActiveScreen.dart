import 'package:buzz/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/config/config.dart';
// Widgets
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Title.dart';

// Função utilitária para decodificar as respostas HTTP
dynamic decodeJsonResponse(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    return json.decode(responseBody);
  } else {
    throw Exception(
        'Failed to parse JSON, status code: ${response.statusCode}');
  }
}

class StudentTripActiveScreen extends StatefulWidget {
  final int tripId; // Campo para o ID da viagem

  StudentTripActiveScreen({required this.tripId});

  @override
  _StudentTripActiveScreenState createState() =>
      _StudentTripActiveScreenState();
}

class _StudentTripActiveScreenState extends State<StudentTripActiveScreen> {
  List<Map<String, String>> busStops = [];
  bool isLoading = true;
  bool _busIssue = false;

  @override
  void initState() {
    super.initState();
    fetchBusStops();
  }

  Future<void> fetchBusStops() async {
    final String url = '${Config.backendUrl}/trips/${widget.tripId}/bus_stops';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = decodeJsonResponse(response);

        setState(() {
          _busIssue =
              data['bus_issue'] ?? false; // Verifica o estado do problema
          busStops = (data['bus_stops'] as List<dynamic>).map((item) {
            // Verifica se o status é "Já passou" e mantém o status original
            String status = item['status'] as String;
            if (_busIssue && status != 'Já passou') {
              status = 'Ônibus com problema';
            }
            return {
              'name': item['name'] as String,
              'status': status,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Widget> _generateTripBusStopWidgets() {
    return busStops.map((data) {
      final status = _busIssue && data['status'] != 'Já passou'
          ? 'Ônibus com problema'
          : data['status']!;
      return Padding(
        padding: EdgeInsets.symmetric(
            vertical: getHeightProportion(
                context, 5.0)), // Proporção para o espaçamento vertical
        child: TripBusStop(
          onPressed: () {
            // Adicione a ação a ser executada ao pressionar
          },
          busStopName: data['name']!,
          busStopStatus: status,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Exibe o loading enquanto os dados são carregados
            : Column(
                children: [
                  SizedBox(
                      height: getHeightProportion(context,
                          40)), // Proporção para o espaçamento vertical
                  CustomTitleWidget(title: 'Viagem atual'),
                  SizedBox(
                      height: getHeightProportion(context,
                          10)), // Proporção para o espaçamento vertical
                  Expanded(
                    child: ListView(
                      children: _generateTripBusStopWidgets(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
