import 'package:buzz/screens/Driver/driver_bus_stop_inactive_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'driver_bus_stop_active_screen.dart';

class DriverScreenController extends StatelessWidget {
  final int driverId;

  DriverScreenController({required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        if (tripController.hasActiveTrip && tripController.activeTripId != null) {
          return DriverBusStopActiveScreen(
            endTrip: () async {
              try {
                if (tripController.activeTripId != null) {
                  await tripController.completeTrip(tripController.activeTripId!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Trip completed successfully"),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("No active trip ID found"),
                  ));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Failed to complete trip: $e"),
                ));
              }
            },
            tripId: tripController.activeTripId!,  // Passar o tripId para a tela
          );
        } else {
          return DriverBusStopInactiveScreen(
            startTrip: tripController.initiateTrip,
            driverId: driverId,
          );
        }
      },
    );
  }
}
