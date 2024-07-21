import 'package:buzz/screens/Driver/driver_bus_stop_screen_controller.dart';
import 'package:buzz/screens/Driver/driver_student_screen_controller.dart';
import 'package:buzz/screens/Student/StudentTripActiveScreen.dart';
import 'package:buzz/screens/Student/student_trip_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:buzz/screens/Student/student_home_screen_controller.dart';
import 'package:buzz/utils/navbar_helper.dart';
import 'package:buzz/screens/Student/student_home_trip_active_screen.dart';
import 'package:buzz/screens/Student/student_profile_screen.dart';
import 'package:buzz/screens/Driver/driver_profile_screen.dart';
import 'package:buzz/screens/Admin/admin_home_screen.dart';
import 'package:buzz/screens/Admin/admin_profile_screen.dart';
import 'package:buzz/models/usuario.dart';


class MainScreen extends StatefulWidget {
  final Usuario usuario;

  MainScreen({required this.usuario});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = _getScreensForUser(widget.usuario.tipoUsuario);
  }

  List<Widget> _getScreensForUser(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'student':
        return [
          StudentTripScreenController(), // Tela de viagem
          StudentHomeScreenController(), // Tela principal
          StudentProfileScreen(
            imagePath: 'assets/images/profliepic.jpeg', 
            studentName: 'Pedro Henrique Mendes',
            email: 'pedrohm@hotmail.com', 
            cpf: '11111111111', 
            course: 'Eng. Software', 
            university: 'Universidade de Rio Verde',
          ),
        ];
      case 'driver':
        return [
          DriverStudentScreenController(),
          DriverScreenController(),
          DriverProfileScreen(
            imagePath: 'assets/images/profliepic.jpeg',
            adminName: 'Admin Name',
            email: 'admin@email.com',
            cpf: '123.456.789-00',
          ),
        ];
      case 'admin':
        return [
          AdminHomeScreen(), // Home Screen
          AdminProfileScreen(
            imagePath: 'assets/images/profliepic.jpeg',
            adminName: 'Admin Name',
            email: 'admin@email.com',
            cpf: '123.456.789-00',
          ),
        ];
      default:
        throw Exception('Tipo de usuário desconhecido');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: getNavBar(widget.usuario.tipoUsuario, _currentIndex, _onItemTapped),
    );
  }
}
