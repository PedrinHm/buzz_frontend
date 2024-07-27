import 'package:buzz/screens/Auth/login_screen.dart';
import 'package:flutter/material.dart'; 

//widgets
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Button_One.dart';
import 'package:buzz/widgets/Geral/Text_Button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController cpfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputField(
                    labelText: 'CPF',
                    keyboardType: TextInputType.number,
                    controller: cpfController,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Button_One(
              buttonText: 'Enviar para meu e-mail',
              onPressed: () {
                print('Botão pressionado! CPF: ${cpfController.text}');
              },
            ),
            TextLinkButton(
              text: 'Voltar',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
