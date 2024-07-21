import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:flutter/material.dart';

class DriverHomeScreen extends StatelessWidget {
  final VoidCallback startTrip;

  DriverHomeScreen({required this.startTrip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nenhuma viagem em andamento.',
                  style: TextStyle(
                    color: Color(0xFF000000).withOpacity(0.70),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Center(
              child: ButtonThree(
                buttonText: 'Iniciar Viagem',
                onPressed: startTrip,
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
