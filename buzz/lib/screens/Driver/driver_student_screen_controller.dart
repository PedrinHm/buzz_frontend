import 'package:buzz/screens/Driver/driver_student_active_screen.dart';
import 'package:flutter/material.dart';
import '../../controllers/trip_controller.dart';
import 'driver_student_inactive_screen.dart';
import 'package:provider/provider.dart';

class DriverStudentScreenController extends StatelessWidget {
  final int driverId;

  DriverStudentScreenController({required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        return tripController.hasActiveTrip
            ? DriverStudentActiveScreen(endTrip: tripController.endTrip)
            : DriverStudentInactiveScreen(
                startTrip: tripController.initiateTrip,
                driverId: driverId,
              );
      },
    );
  }
}
