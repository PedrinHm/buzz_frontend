import 'package:flutter/material.dart'; 

//screens
import 'package:buzz/screens/auth/forgot_password_screen.dart';

//widgets
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/One_Button.dart';
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
