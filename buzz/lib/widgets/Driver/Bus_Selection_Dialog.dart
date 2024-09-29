import 'package:buzz/screens/Admin/form_screen.dart';
import 'package:buzz/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';

class BusSelectionDialog extends StatelessWidget {
  final Function(int) onBusSelected;
  final String url;

  BusSelectionDialog({required this.onBusSelected, required this.url});

  // Atualizando para usar a função decodeJsonResponse
  Future<List<Map<String, dynamic>>> _fetchAvailableBuses() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(decodeJsonResponse(response));
    } else {
      throw Exception('Failed to load buses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(getWidthProportion(context, 16))),  // Aplicando proporção
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(getHeightProportion(context, 16.0)),  // Aplicando proporção
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Defina seu ônibus atual',
                    style: TextStyle(
                      fontSize: getHeightProportion(context, 18),  // Aplicando proporção
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: getHeightProportion(context, 20)),  // Aplicando proporção
                  Expanded(
                    child: ListView.builder(
                      itemCount: buses.length,
                      itemBuilder: (context, index) {
                        final bus = buses[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: getHeightProportion(context, 20.0)),  // Aplicando proporção
                          child: BusDetailsButton(
                            onPressed: () {
                              if (bus['id'] != null) {
                                onBusSelected(bus['id']); // Somente chama se 'id' não for null
                              } else {
                                print('Erro: ID do ônibus é nulo');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao selecionar o ônibus: ID inválido.')),
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
