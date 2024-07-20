import 'package:flutter/material.dart';

class CustomTitleWidget extends StatelessWidget {
  final String title;

  CustomTitleWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      height: MediaQuery.of(context).size.height * (50 / 932),
      decoration: BoxDecoration(
        color: Color(0xFF395BC7),
        borderRadius: BorderRadius.circular(10), // Ajuste o valor para arredondar mais ou menos as bordas
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.normal, // semibold
          fontFamily: 'Inter', // Certifique-se de ter a fonte 'Inter' incluída no seu projeto
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}