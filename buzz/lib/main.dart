import 'package:flutter/material.dart';
import 'package:buzz/screens/Auth/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Defina a família de fontes padrão como Inter
      ),
      home: LoginScreen(),
    );
  }
}
