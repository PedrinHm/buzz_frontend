import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'student_home_trip_active_screen.dart';
import 'student_home_trip_inactive_screen.dart';

class StudentHomeScreenController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        return tripController.hasActiveTrip
            ? StudentHomeTripActiveScreen()
            : StudentHomeTripInactiveScreen();
      },
    );
  }
}
