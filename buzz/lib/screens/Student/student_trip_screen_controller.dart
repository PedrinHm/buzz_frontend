import 'package:buzz/screens/Student/StudentTripActiveScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'student_trip_inactive_screen.dart';

class StudentTripScreenController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        return tripController.hasActiveTrip
            ? StudentTripActiveScreen()
            : StudentTripInactiveScreen();
      },
    );
  }
}
