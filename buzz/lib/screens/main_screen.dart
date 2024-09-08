import 'package:buzz/screens/Driver/bus_stop_screen_controller.dart';
import 'package:buzz/screens/Driver/student_bus_stop_screen_controller.dart';
import 'package:buzz/screens/Geral/user_profile_screen.dart';
import 'package:buzz/screens/Student/student_trip_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:buzz/screens/Student/student_home_screen_controller.dart';
import 'package:buzz/utils/navbar_helper.dart';
import 'package:buzz/screens/Admin/home_screen.dart';
import 'package:buzz/models/usuario.dart';
import 'package:provider/provider.dart';
import 'package:buzz/controllers/trip_controller.dart';

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

  Future<void> _verifyControllers() async {
    if (widget.usuario.tipoUsuario == 'driver') {
      await Provider.of<TripController>(context, listen: false).checkActiveTrip(widget.usuario.id);
    }
    // Adicione mais verificações se necessário
  }

List<Widget> _getScreensForUser(String tipoUsuario) {
  switch (tipoUsuario) {
    case 'student':
      return [
        StudentTripScreenController(studentId: widget.usuario.id),
        StudentHomeScreenController(studentId: widget.usuario.id),
        UserProfileScreen(userId: widget.usuario.id), // Passando apenas o userId
      ];
    case 'driver':
      return [
        DriverStudentScreenController(driverId: widget.usuario.id),
        BusStopScreenController(driverId: widget.usuario.id),
        UserProfileScreen(userId: widget.usuario.id), // Passando apenas o userId
      ];
    case 'admin':
      _currentIndex = 0;
      return [
        HomeScreen(),
        UserProfileScreen(userId: widget.usuario.id), // Passando apenas o userId
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
    return FutureBuilder<void>(
      future: _verifyControllers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar os dados.'));
        } else {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: getNavBar(widget.usuario.tipoUsuario, _currentIndex, _onItemTapped),
          );
        }
      },
    );
  }
}
