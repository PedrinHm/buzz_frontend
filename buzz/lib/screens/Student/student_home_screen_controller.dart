import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'student_home_trip_active_screen.dart';
import 'student_home_trip_inactive_screen.dart';

class StudentHomeScreenController extends StatefulWidget {
  final int studentId; // Adicione o ID do aluno se necessário

  StudentHomeScreenController({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentHomeScreenControllerState createState() => _StudentHomeScreenControllerState();
}

class _StudentHomeScreenControllerState extends State<StudentHomeScreenController> {
  @override
  void initState() {
    super.initState();
    // Chama a verificação de viagem ativa para o aluno quando o widget é construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripController = Provider.of<TripController>(context, listen: false);
      tripController.checkActiveStudentTrip(widget.studentId);
    });
  }

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
