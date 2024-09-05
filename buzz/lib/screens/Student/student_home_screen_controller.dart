import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'student_home_trip_active_screen.dart';
import 'student_home_trip_inactive_screen.dart';

class StudentHomeScreenController extends StatefulWidget {
  final int studentId;

  StudentHomeScreenController({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentHomeScreenControllerState createState() => _StudentHomeScreenControllerState();
}

class _StudentHomeScreenControllerState extends State<StudentHomeScreenController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripController = Provider.of<TripController>(context, listen: false);
      tripController.checkActiveTrip(widget.studentId, isStudent: true); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        if (tripController == null) {
          return Center(child: CircularProgressIndicator());
        }

        if (!tripController.hasActiveTrip) {
          return StudentHomeTripInactiveScreen(studentId: widget.studentId);
        } else {
          // Verifica se o studentTripId foi definido
          if (tripController.studentTripId == null) {
            print("Erro: Student Trip ID não encontrado.");
            return Center(child: Text("Erro: Student Trip ID não encontrado."));
          }

          return StudentHomeTripActiveScreen(
            studentId: widget.studentId,
            tripId: tripController.activeTripId ?? 0, 
            studentTripId: tripController.studentTripId!, 
          );
        }
      },
    );
  }
}
