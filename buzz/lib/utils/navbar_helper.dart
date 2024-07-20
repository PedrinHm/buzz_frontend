import 'package:buzz/widgets/Student/Nav_Bar_Student.dart';
import 'package:flutter/material.dart';
import 'package:buzz/widgets/Driver/driver_nav_bar.dart';
import 'package:buzz/widgets/Admin/nav_bar_admin.dart';

StatelessWidget getNavBar(String tipoUsuario, int currentIndex, ValueChanged<int> onTap) {
  switch (tipoUsuario) {
    case 'student':
      return StudentNavBar(currentIndex: currentIndex, onTap: onTap);
    case 'driver':
      return DriverNavBar(currentIndex: currentIndex, onTap: onTap);
    case 'admin':
      return NavBarAdmin(currentIndex: currentIndex, onTap: onTap);
    default:
      throw Exception('Tipo de usuário desconhecido');
  }
}
