import 'package:buzz/screens/login_screen.dart';
import 'package:flutter/material.dart'; 

//widgets
import 'package:buzz/widgets/CustomInputField.dart';
import 'package:buzz/widgets/CustomElevatedButton.dart';
import 'package:buzz/widgets/TextLinkButton';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              buttonText: 'Enviar para meu e-mail',
              onPressed: () {
                print('Botão pressionado!');  
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
