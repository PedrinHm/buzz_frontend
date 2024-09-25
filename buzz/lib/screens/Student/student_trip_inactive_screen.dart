import 'package:buzz/utils/size_config.dart';
import 'package:flutter/material.dart';

class StudentTripInactiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Você não está em nenhuma viagem atualmente.',
              style: TextStyle(
                color: Color(0xFF000000).withOpacity(0.70),
                fontSize: getHeightProportion(context, 16), // Proporção para altura
              ),
            ),
          ],
        ),
      ),
    );
  }
}
