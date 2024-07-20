import 'package:buzz/screens/studentProfile.dart';
import 'package:buzz/screens/studentTrip_screen.dart';
import 'package:flutter/material.dart';
import '/screens/login_screen.dart';  // Ajuste o caminho conforme necessário
import 'screens/studentHome_screen.dart';
void main() {
  runApp(
    MaterialApp(
      home: studentProfileScreen(),  // Usando LoginScreen como a tela inicial
    ),
  );
}
