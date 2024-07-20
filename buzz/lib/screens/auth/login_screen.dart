import 'package:flutter/material.dart'; 

//screens
import 'package:buzz/screens/Auth/forgot_password_screen.dart';

//widgets
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Button_One.dart';
import 'package:buzz/widgets/Geral/Text_Button.dart';

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
                    keyboardType: TextInputType.emailAddress, controller: null,
                  ),
                  SizedBox(height: 20),
                  CustomInputField(
                    labelText: 'Senha',
                    obscureText: true, controller: null,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Button_One(
              buttonText: 'Realizar Login',
              onPressed: () {
                print('Botão pressionado!');  
              },
            ),             
            TextLinkButton(
              text: 'Esqueceu a senha?',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                );    
              },
            ),
          ],
        ),
      ),
    );
  }
}
