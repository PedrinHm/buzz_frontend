import 'package:flutter/material.dart'; 
import 'package:phosphor_flutter/phosphor_flutter.dart';

//widgets
import 'package:buzz/widgets/Geral/Nav_Bar.dart';
import 'package:buzz/widgets/Student/Bus_Button_Home.dart';
import 'package:buzz/widgets/Student/Bus_Stop_Button_Home.dart';
import 'package:buzz/widgets/Student/Status_Button_Home.dart';
import 'package:buzz/widgets/Student/Message_Home.dart';

class StudentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          SizedBox(height: 40),
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
    );
  }
}
