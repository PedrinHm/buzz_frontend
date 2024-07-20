import 'package:buzz/widgets/Custom_Bus_Button.dart';
import 'package:buzz/widgets/Custom_Bus_Stop_Button.dart';
import 'package:buzz/widgets/Custom_Status.dart';
import 'package:buzz/widgets/FullScreenMessage.dart';
import 'package:buzz/widgets/StudentProfile.dart';
import 'package:flutter/material.dart'; 

//widgets
import 'package:buzz/widgets/CustomInputField.dart';
import 'package:buzz/widgets/CustomElevatedButton.dart';
import 'package:buzz/widgets/TextLinkButton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/widgets/bottom_nav_bar.dart';

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
