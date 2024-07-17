import 'package:flutter/material.dart'; 

//widgets
import 'package:buzz/widgets/CustomInputField.dart';
import 'package:buzz/widgets/CustomElevatedButton.dart';
import 'package:buzz/widgets/TextLinkButton';

class LoginScreen extends StatelessWidget {
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
                    labelText: 'Login',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  CustomInputField(
                    labelText: 'Senha',
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            CustomElevatedButton(
              buttonText: 'Realizar Login',
              onPressed: () {
                print('Botão pressionado!');  
              },
            ),             
            TextLinkButton(
              text: 'Esqueceu a senha?',
              onPressed: () {
                print('Esqueceu a senha clicado!');  
              },
            ),
          ],
        ),
      ),
    );
  }
}
