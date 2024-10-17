import 'package:buzz/screens/Admin/form_screen.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';
import 'package:buzz/widgets/Geral/buildOverlay.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/config/config.dart';

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
  bool isStartingTrip = false;
  List<Map<String, dynamic>> _busList = [];

  Future<void> _fetchAvailableBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('${Config.backendUrl}/buses/available'));

      if (response.statusCode == 200) {
        final data = decodeJsonResponse(response);
        setState(() {
          _busList = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Falha ao carregar ônibus disponíveis.');
      }
    } catch (e) {
      print('Erro ao buscar ônibus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar ônibus disponíveis'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleBusOverlay() {
    setState(() {
      _showBusOverlay = !_showBusOverlay;
      if (_showBusOverlay) {
        _fetchAvailableBuses();
      }
    });
  }

  Future<void> _startTrip(int busId) async {
    setState(() {
      isStartingTrip = true;
    });

    try {
      await widget.startTrip(widget.driverId, busId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viagem iniciada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar a viagem'),
          backgroundColor: Colors.red, 
        ),
      );
    } finally {
      setState(() {
        isStartingTrip = false;
        _toggleBusOverlay();
      });
    }
  }

  Widget _buildBusList() {
    return ListView.builder(
      itemCount: _busList.length,
      itemBuilder: (context, index) {
        final bus = _busList[index];

        final busNumber = bus['registration_number'] ?? 'Número desconhecido';
        final driverName = bus['name'] ?? 'Nome desconhecido';
        final busId = bus['id'];

        return Padding(
          padding: EdgeInsets.only(bottom: getHeightProportion(context, 20)),
          child: BusDetailsButton(
            onPressed: () async {
              if (busId != null) {
                await _startTrip(busId);
              } else {
                print('Erro: busId é nulo');
              }
            },
            busNumber: busNumber,
            driverName: driverName,
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
                    fontSize:
                        getHeightProportion(context, 16), 
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: getHeightProportion(context, 20.0), 
            left: 0,
            right: 0,
            child: Center(
              child: ButtonThree(
                buttonText: 'Iniciar Viagem',
                onPressed: _toggleBusOverlay, 
                backgroundColor: Color(0xFF395BC7),
              ),
            ),
          ),
          if (_showBusOverlay)
            BuildOverlay(
              title: 'Selecione um Ônibus',
              content: isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator())
                  : _buildBusList(), 
              onCancel: _toggleBusOverlay, 
            ),
          if (isStartingTrip)
            Center(
                child:
                    CircularProgressIndicator()), 
        ],
      ),
    );
  }
}
