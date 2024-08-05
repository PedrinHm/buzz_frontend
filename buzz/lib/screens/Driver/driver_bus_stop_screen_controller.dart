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
        return tripController.hasActiveTrip
            ? DriverBusStopActiveScreen(
                endTrip: () async {
                  if (tripController.activeTripId != null) {
                    await tripController.completeTrip(tripController.activeTripId!);
                  }
                },
              )
            : DriverBusStopInactiveScreen(
                startTrip: tripController.initiateTrip,
                driverId: driverId,
              );
      },
    );
  }
}
