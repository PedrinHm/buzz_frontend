import 'package:flutter/material.dart'; 

//widgets
import 'package:buzz/widgets/Geral/Nav_Bar.dart';
import 'package:buzz/widgets/student/Student_Profile.dart';

class studentProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
        StudentProfileScreen(
          imagePath: 'lib/assets/profliepic.jpeg', // Substitua pelo caminho da sua imagem
          studentName: 'Pedro Henrique Mendes',
          email: 'pedro@email.com',
          cpf: '111.111.111-00',
          course: 'Eng. Software',
          university: 'Universidade de Rio Verde',
        ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
