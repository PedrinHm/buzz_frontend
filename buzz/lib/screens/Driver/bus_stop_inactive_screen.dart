import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';
import 'package:buzz/widgets/Geral/buildOverlay.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusStopInactiveScreen extends StatefulWidget {
  final Future<void> Function(int driverId, int busId) startTrip;
  final int driverId;

  BusStopInactiveScreen({required this.startTrip, required this.driverId});

  @override
  _BusStopInactiveScreenState createState() => _BusStopInactiveScreenState();
}

class _BusStopInactiveScreenState extends State<BusStopInactiveScreen> {
  bool _showBusOverlay = false;
  bool isLoading = false;
  List<Map<String, dynamic>> _busList = [];

  // Função para buscar os ônibus disponíveis
  Future<void> _fetchAvailableBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://buzzbackend-production.up.railway.app/buses/available'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _busList = data.map((item) => {
            'busId': item['bus_id'],
            'tripId': item['trip_id'],
            'registrationNumber': item['registration_number'],
            'name': item['name'],
            'capacity': item['capacity'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load available buses');
      }
    } catch (e) {
      print('Erro ao buscar ônibus disponíveis: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar ônibus disponíveis')),
      );
    } finally {
      setState(() {
        isLoading = false;
        _showBusOverlay = true; // Exibe o overlay ao buscar os ônibus
      });
    }
  }

  // Função para construir a lista de ônibus disponíveis
  Widget _buildBusList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_busList.isEmpty) {
      return Center(child: Text('Nenhum ônibus disponível no momento.'));
    }

    return ListView.builder(
      itemCount: _busList.length,
      itemBuilder: (context, index) {
        final bus = _busList[index];
        return Padding(
          padding: EdgeInsets.only(bottom: getHeightProportion(context, 20)),
          child: BusDetailsButton(
            onPressed: () {
              widget.startTrip(widget.driverId, bus['busId']);
              setState(() {
                _showBusOverlay = false; 
              });
            },
            busNumber: bus['registrationNumber'],
            driverName: bus['name'],
            capacity: bus['capacity'],
            availableSeats: 0, 
            color: Color(0xFF395BC7),
          ),
        );
      },
    );
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
                  'Nenhuma viagem em andamento.',
                  style: TextStyle(
                    color: Color(0xFF000000).withOpacity(0.70),
                    fontSize: getHeightProportion(context, 16), // Proporção ajustada
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: getHeightProportion(context, 20.0), // Proporção ajustada
            left: 0,
            right: 0,
            child: Center(
              child: ButtonThree(
                buttonText: 'Iniciar Viagem',
                onPressed: _fetchAvailableBuses, // Busca os ônibus ao clicar
                backgroundColor: Color(0xFF395BC7),
              ),
            ),
          ),
          if (_showBusOverlay)
            BuildOverlay(
              title: 'Selecione um Ônibus',
              content: _buildBusList(), // Constrói a lista de ônibus
              onCancel: () {
                setState(() {
                  _showBusOverlay = false; // Fecha o overlay ao cancelar
                });
              },
            ),
        ],
      ),
    );
  }
}
