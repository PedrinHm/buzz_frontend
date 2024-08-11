import 'package:buzz/screens/Driver/driver_bus_stop_inactive_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/trip_controller.dart';
import 'driver_bus_stop_active_screen.dart';

class DriverScreenController extends StatelessWidget {
  final int driverId;

  DriverScreenController({required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripController>(
      builder: (context, tripController, child) {
        if (tripController.hasActiveTrip && tripController.activeTripId != null) {
          return DriverBusStopActiveScreen(
            endTrip: () async {
              try {
                if (tripController.activeTripId != null) {
                  await tripController.completeTrip(tripController.activeTripId!);
                  if (tripController.tripType == 2) { // Se for VOLTA
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Viagem concluída com sucesso"),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Viagem de ida concluída. Iniciando viagem de volta..."),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Nenhum ID de viagem ativa encontrado"),
                  ));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Falha ao concluir a viagem: $e"),
                ));
              }
            },
            tripId: tripController.activeTripId!,
            isReturnTrip: tripController.tripType == 2, // Passando o tripType
          );
        } else {
          return DriverBusStopInactiveScreen(
            startTrip: (int driverId, int busId) {
              return tripController.initiateTrip(driverId, busId, 1); // Aqui, estou assumindo que o tipo de viagem padrão é '1' (IDA)
            },
            driverId: driverId,
          );
        }
      },
    );
  }
}
