import 'package:buzz/screens/Student/StudentTripActiveScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'student_trip_inactive_screen.dart';

class StudentTripScreenController extends StatefulWidget {
  final int studentId; // ID do aluno
  
  StudentTripScreenController({Key? key, required this.studentId}) : super(key: key);
    
  @override
  _StudentTripScreenControllerState createState() => _StudentTripScreenControllerState();
}

class _StudentTripScreenControllerState extends State<StudentTripScreenController> {
  @override
  void initState() {
    super.initState();
    // Chama a verificação de viagem ativa para o aluno quando o widget é construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripController = Provider.of<TripController>(context, listen: false);
      tripController.checkActiveTrip(widget.studentId, isStudent: true); // Usa checkActiveTrip com isStudent definido como true
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        return tripController.hasActiveTrip
            ? StudentTripActiveScreen(tripId: tripController.activeTripId!) // Passa o ID da viagem ativa
            : StudentTripInactiveScreen();
      },
    );
  }
}
