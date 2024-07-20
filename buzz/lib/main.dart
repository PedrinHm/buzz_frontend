import 'package:buzz/screens/Student/student_home_screen.dart';
import 'package:buzz/screens/Student/student_profile_screen.dart';
import 'package:buzz/screens/Student/student_trip_screen.dart';
import 'package:buzz/widgets/Geral/Nav_Bar.dart';
import 'package:flutter/material.dart';


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
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = [
    StudentTripScreen(),
    StudentHomeScreen(),
    StudentProfileScreen(
      imagePath: 'assets/images/profliepic.jpeg',
      studentName: 'Pedro Henrique Mendes',
      email: 'pedro@email.com',
      cpf: '111.111.111-00',
      course: 'Eng. Software',
      university: 'Universidade de Rio Verde',
    ),
  ];

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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
