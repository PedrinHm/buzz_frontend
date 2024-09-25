import 'package:buzz/screens/Driver/student_bus_stop_active_screen.dart';
import 'package:flutter/material.dart';
import '../../controllers/trip_controller.dart';
import 'package:provider/provider.dart';
import 'package:buzz/utils/size_config.dart'; // Importar funções de tamanho

class DriverStudentScreenController extends StatelessWidget {
  final int driverId;

  DriverStudentScreenController({required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        if (tripController.hasActiveTrip && tripController.activeTripId != null) {
          return StudentBusStopActiveScreen(
            endTrip: tripController.endTrip,
            tripId: tripController.activeTripId!,
          );
        } else {
          return Center(
            child: Text(
              'Nenhuma viagem em andamento.',
              style: TextStyle(
                color: Color(0xFF000000).withOpacity(0.70),
                fontSize: getHeightProportion(context, 16),  // Proporção ajustada
              ),
            ),
          );
        }
      },
    );
  }
}
