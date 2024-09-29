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
        if (tripController.hasActiveTrip && tripController.activeTripId != null) {
          return BusStopActiveScreen(
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
              } finally {
                // Garantir que o refresh da tela seja feito, independente do resultado
                setState(() {
                  // Ação que causa o refresh da tela
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => BusStopScreenController(driverId: widget.driverId),
                    ),
                  );
                });
              }
            },
            tripId: tripController.activeTripId!,
            isReturnTrip: tripController.tripType == 2, // Passando o tripType
          );
        } else {
          return BusStopInactiveScreen(
            startTrip: (int driverId, int busId) {
              return tripController.initiateTrip(driverId, busId, 1); // Aqui, estou assumindo que o tipo de viagem padrão é '1' (IDA)
            },
            driverId: widget.driverId,
          );
        }
      },
    );
  }
}
