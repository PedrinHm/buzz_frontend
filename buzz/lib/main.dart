import 'package:buzz/screens/Admin/admin_home_screen.dart';
import 'package:buzz/screens/Admin/admin_profile_screen.dart';
import 'package:buzz/widgets/Admin/Nav_Bar_Admin.dart';
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
        fontFamily: 'Inter', // Defina a família de fontes padrão como Inter
      ),
      home: AdminMainScreen(),
      routes: {
        '/adminHome': (context) => AdminHomeScreen(),
        '/adminProfile': (context) => AdminProfileScreen(
          imagePath: 'assets/images/profliepic.jpeg',
          adminName: 'Admin Name',
          email: 'admin@email.com',
          cpf: '123.456.789-00',
        ),
      },
    );
  }
}

class AdminMainScreen extends StatefulWidget {
  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AdminHomeScreen(),
    AdminProfileScreen(
      imagePath: 'assets/images/profliepic.jpeg',
      adminName: 'Admin Name',
      email: 'admin@email.com',
      cpf: '123.456.789-00',
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
      bottomNavigationBar: NavBarAdmin(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
