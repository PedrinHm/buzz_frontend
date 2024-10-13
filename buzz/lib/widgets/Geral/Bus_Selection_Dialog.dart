import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:buzz/utils/size_config.dart'; 
import '../../services/decodeJsonResponse.dart';

class BusSelectionDialog extends StatelessWidget {
  final Function(int, int, int)
      onBusSelected; 
  final String url;

  BusSelectionDialog({required this.onBusSelected, required this.url});

  Future<List<Map<String, dynamic>>> _fetchAvailableBuses() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> buses =
          List<Map<String, dynamic>>.from(decodeJsonResponse(response));
      print(
          'Dados recebidos dos ônibus: $buses'); // Debug print dos dados recebidos dos ônibus
      return buses;
    } else {
      print(
          'Erro ao carregar ônibus: ${response.statusCode} - ${response.reasonPhrase}'); // Debug print em caso de erro
      throw Exception('Failed to load buses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              getWidthProportion(context, 16))), // Proporção aplicada
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(
            getHeightProportion(context, 16.0)), // Proporção aplicada
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchAvailableBuses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No available buses'));
            } else {
              final buses = snapshot.data!;
              print(
                  'Ônibus disponíveis: $buses'); // Debug print dos ônibus disponíveis
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Defina seu ônibus atual',
                    style: TextStyle(
                      fontSize: getHeightProportion(
                          context, 18), // Proporção aplicada
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                      height: getHeightProportion(
                          context, 20)), // Proporção aplicada
                  Expanded(
                    child: ListView.builder(
                      itemCount: buses.length,
                      itemBuilder: (context, index) {
                        final bus = buses[index];
                        print(
                            'Dados do ônibus: $bus'); // Debug print dos dados de cada ônibus
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: getHeightProportion(
                                  context, 20.0)), // Proporção aplicada
                          child: BusDetailsButton(
                            onPressed: () {
                              // Use as chaves corretas 'bus_id', 'trip_id', e 'trip_type'
                              if (bus['bus_id'] != null &&
                                  bus['trip_id'] != null &&
                                  bus['trip_type'] != null) {
                                // Chame a função de seleção com as chaves corretas
                                onBusSelected(bus['bus_id'], bus['trip_id'],
                                    bus['trip_type'] == 'Ida' ? 1 : 2);
                              } else {
                                print(
                                    'Erro: Dados insuficientes para a seleção do ônibus');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Erro ao selecionar o ônibus: dados inválidos.')),
                                );
                              }
                            },
                            busNumber: bus['registration_number'],
                            driverName: bus['name'],
                            capacity: bus['capacity'],
                            color: Color(0xFF395BC7),
                          ),
                        );
                      },
                    ),
                  ),
                  ButtonThree(
                    buttonText: 'Cancelar',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
