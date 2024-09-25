import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/utils/size_config.dart'; // Import das funções de proporção

class DriverNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  DriverNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            PhosphorIcons.mapPin,
            size: getHeightProportion(context, 24), // Aplicando proporção no tamanho do ícone
          ),
          label: 'Trip',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            PhosphorIcons.houseSimple,
            size: getHeightProportion(context, 24), // Aplicando proporção no tamanho do ícone
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            PhosphorIcons.user,
            size: getHeightProportion(context, 24), // Aplicando proporção no tamanho do ícone
          ),
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
