import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.mapPin),
          label: 'Rotas',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.houseSimple),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.user),
          label: 'Perfil',
        ),
      ],
      currentIndex: 0,  // Por padrão, a primeira aba será selecionada
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.60), // Cor dos ícones não selecionados
      backgroundColor: Color(0xFF395BC7), 
      showSelectedLabels: false,  // Não mostra labels quando um item está selecionado
      showUnselectedLabels: false,  // Cor de fundo da barra de navegação
      onTap: (index) {
        // Aqui você pode adicionar a lógica de navegação
        print('Item $index selecionado');
      },
    );
  }
}
