import 'package:flutter/material.dart';
import '/screens/login_screen.dart';  // Ajuste o caminho conforme necessário
import '/screens/student_home_screen.dart';
void main() {
  runApp(
    MaterialApp(
      home: studentHomeScreen(),  // Usando LoginScreen como a tela inicial
    ),
  );
}
