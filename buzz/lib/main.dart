import 'package:buzz/screens/Student/student_profile_screen.dart';
import 'package:buzz/screens/Student/student_trip_screen.dart';
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';  // Ajuste o caminho conforme necessário
import 'screens/Student/student_home_screen.dart';
void main() {
  runApp(
    MaterialApp(
      home: studentProfileScreen(),  // Usando LoginScreen como a tela inicial
    ),
  );
}
