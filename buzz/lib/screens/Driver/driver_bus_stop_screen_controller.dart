import 'package:buzz/screens/Driver/driver_bus_stop_active_screen.dart';
import 'package:buzz/screens/Driver/driver_bus_stop_inactive_screen.dart.dart';
import 'package:flutter/material.dart';
import '../../controllers/trip_controller.dart';
import 'package:provider/provider.dart';

class DriverScreenController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        return tripController.hasActiveTrip
            ? DriverActiveTripScreen(endTrip: tripController.endTrip)
            : DriverHomeScreen(startTrip: tripController.startTrip);
      },
    );
  }
}
