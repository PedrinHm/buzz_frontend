import 'package:buzz/screens/Driver/driver_bus_stop_active_screen.dart';
import 'package:buzz/screens/Driver/driver_bus_stop_inactive_screen.dart.dart';
import 'package:flutter/material.dart';
import '../../controllers/trip_controller.dart';
import 'package:provider/provider.dart';

class DriverScreenController extends StatelessWidget {
  final int driverId;
  final int busId; // Assuming you have the bus ID available

  DriverScreenController({required this.driverId, required this.busId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        return tripController.hasActiveTrip
            ? DriverBusStopActiveScreen(
                endTrip: () async {
                  // Aqui você deve passar o ID da viagem ativa
                  await tripController.completeTrip(1); // Substitua 1 pelo ID real da viagem
                },
              )
            : DriverBusStopInactiveScreen(
                startTrip: () async {
                  await tripController.initiateTrip(driverId, busId);
                },
              );
      },
    );
  }
}
