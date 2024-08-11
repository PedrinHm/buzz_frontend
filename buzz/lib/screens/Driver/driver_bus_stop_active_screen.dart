import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Title.dart';

class DriverBusStopActiveScreen extends StatefulWidget {
  final VoidCallback endTrip;
  final int tripId;

  DriverBusStopActiveScreen({required this.endTrip, required this.tripId});

  @override
  _DriverBusStopActiveScreenState createState() => _DriverBusStopActiveScreenState();
}

class _DriverBusStopActiveScreenState extends State<DriverBusStopActiveScreen> {
  List<Map<String, String>> tripBusStops = [];

  @override
  void initState() {
    super.initState();
    fetchBusStops().then((data) {
      setState(() {
        tripBusStops = data;
      });
    });
  }

Future<List<Map<String, String>>> fetchBusStops() async {
  var url = Uri.parse('http://127.0.0.1:8000/trips/${widget.tripId}/bus_stops'); 
  var response = await http.get(url);
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
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


  bool _allStopsPassed() {
    return tripBusStops.every((stop) => stop['status'] == 'Já passou');
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
                      style: TextStyle(fontSize: 18),
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
          if (!_allStopsPassed() && tripBusStops.isNotEmpty)
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
                  onPressed: widget.endTrip,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
