import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Widgets
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Title.dart';

// Função utilitária para decodificar as respostas HTTP
dynamic decodeJsonResponse(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    return json.decode(responseBody);
  } else {
    throw Exception('Failed to parse JSON, status code: ${response.statusCode}');
  }
}

class StudentTripActiveScreen extends StatefulWidget {
  final int tripId; // Campo para o ID da viagem

  StudentTripActiveScreen({required this.tripId});

  @override
  _StudentTripActiveScreenState createState() => _StudentTripActiveScreenState();
}

class _StudentTripActiveScreenState extends State<StudentTripActiveScreen> {
  List<Map<String, String>> busStops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusStops();
  }

  Future<void> fetchBusStops() async {
    // Utilize o tripId fornecido na propriedade do widget
    final String url = 'http://127.0.0.1:8000/trips/${widget.tripId}/bus_stops';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = decodeJsonResponse(response);

        setState(() {
          busStops = data
              .map((item) => {
                    'name': item['name'] as String,
                    'status': item['status'] as String,
                  })
              .toList();
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: TripBusStop(
          onPressed: () {
            // Adicione a ação a ser executada ao pressionar
          },
          busStopName: data['name']!,
          busStopStatus: data['status']!,
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
                  SizedBox(height: 40),
                  CustomTitleWidget(title: 'Viagem atual'),
                  SizedBox(height: 10),
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
