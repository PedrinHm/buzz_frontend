import 'package:buzz/screens/Driver/driver_bus_stop_inactive_screen.dart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'driver_bus_stop_active_screen.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';

class DriverScreenController extends StatelessWidget {
  final int driverId;

  DriverScreenController({required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        return tripController.hasActiveTrip
            ? DriverBusStopActiveScreen(
                endTrip: () async {
                  if (tripController.activeTripId != null) {
                    await tripController.completeTrip(tripController.activeTripId!);
                  }
                },
              )
            : DriverBusStopInactiveScreen(
                startTrip: () async {
                  // Mostrar a lista de ônibus disponíveis
                  final busId = await _showBusSelectionDialog(context);
                  if (busId != null) {
                    await tripController.initiateTrip(driverId, busId);
                  }
                },
              );
      },
    );
  }

  Future<int?> _showBusSelectionDialog(BuildContext context) async {
    final buses = await _fetchAvailableBuses();
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecione um ônibus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ...buses.map((bus) => Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: BusDetailsButton(
                    onPressed: () {
                      Navigator.of(context).pop(bus['id']);
                    },
                    busNumber: bus['registration_number'],
                    driverName: bus['name'],
                    capacity: bus['capacity'],
                    availableSeats: 0, // Ajuste conforme necessário
                    color: Colors.blue,
                  ),
                )),
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
  }

  Future<List<Map<String, dynamic>>> _fetchAvailableBuses() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/buses/available'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load buses');
    }
  }
}
