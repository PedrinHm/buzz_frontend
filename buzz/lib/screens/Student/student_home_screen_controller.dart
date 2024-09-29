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
        if (tripController == null || tripController.isLoading) {
          // Exibe um indicador de carregamento enquanto o tripController está carregando
          return Center(child: CircularProgressIndicator());
        }

        if (!tripController.hasActiveTrip) {
          return StudentHomeTripInactiveScreen(studentId: widget.studentId);
        } else {
          // Verifica se o studentTripId está sendo carregado
          if (tripController.studentTripId == null) {
            // Ainda carregando os detalhes da viagem
            return Center(child: CircularProgressIndicator());
          }

          // Exibe a tela ativa com os dados carregados
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
