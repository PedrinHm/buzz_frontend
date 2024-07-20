import 'package:buzz/widgets/Custom_Bus_Button.dart';
import 'package:buzz/widgets/Custom_Bus_Stop_Button.dart';
import 'package:buzz/widgets/Custom_Status.dart';
import 'package:buzz/widgets/FullScreenMessage.dart';
import 'package:flutter/material.dart'; 

//widgets
import 'package:buzz/widgets/CustomInputField.dart';
import 'package:buzz/widgets/CustomElevatedButton.dart';
import 'package:buzz/widgets/TextLinkButton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/widgets/bottom_nav_bar.dart';

class studentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          SizedBox(height: 10),
          FullScreenMessage(
            message: 'Existem ônibus em viagem de ida, está participando?',
          ),
          SizedBox(height: 10),
          CustomStatus(
            onPressed: () {
              // Defina o que acontece quando o botão é pressionado
            },
            StatusName: 'Em aula',
            iconData: PhosphorIcons.chalkboardTeacher, // Aqui você passa o ícone desejado
          ),
          SizedBox(height: 10),
          CustomBusStopButton(
            onPressed: () {
              print("Botão pressionado");
            },
            busStopName: "ABC-1234",
          ),
          SizedBox(height: 10),
          CustomBusButton(
            onPressed: () {
              print("Botão pressionado");
            },
            busNumber: "ABC-1234",
            driverName: "Nome Do Motorista",
          ),
          SizedBox(height: 10),
        ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
