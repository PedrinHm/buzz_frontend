import 'package:flutter/material.dart';

class StudentHomeTripInactiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
    );
  }
}
