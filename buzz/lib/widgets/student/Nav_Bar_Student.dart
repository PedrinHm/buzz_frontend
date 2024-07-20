import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StudentNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  StudentNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.mapPin),
          label: 'Trip',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.houseSimple),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.user),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.60),
      backgroundColor: Color(0xFF395BC7),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: onTap,
    );
  }
}
