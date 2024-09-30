import 'package:buzz/screens/Driver/bus_stop_inactive_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'bus_stop_active_screen.dart';

class BusStopScreenController extends StatefulWidget {
  final int driverId;

  BusStopScreenController({required this.driverId});

  @override
  _BusStopScreenControllerState createState() => _BusStopScreenControllerState();
}

class _BusStopScreenControllerState extends State<BusStopScreenController> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        if (tripController.activeTripId != null) {
          return BusStopActiveScreen(
            endTrip: () async {
              try {
                await tripController.completeTrip(tripController.activeTripId!);

                if (tripController.activeTripId == null) {
                  // A viagem foi finalizada completamente, então atualizamos a interface
                  setState(() {});
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Erro ao finalizar a viagem: $e"),
                ));
              }
            },
            tripId: tripController.activeTripId!,
            isReturnTrip: tripController.tripType == 2,  // Passando o tripType
          );
        } else {
          // Quando não há mais viagem ativa, exibe a tela inativa
          return BusStopInactiveScreen(
            startTrip: (int driverId, int busId) {
              return tripController.initiateTrip(driverId, busId, 1);  // Inicia uma nova viagem
            },
            driverId: widget.driverId,
          );
        }
      },
    );
  }
}
