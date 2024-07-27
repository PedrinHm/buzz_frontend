import 'package:flutter/material.dart';
import 'package:buzz/screens/Auth/forgot_password_screen.dart';
import 'package:buzz/screens/main_screen.dart';
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Button_One.dart';
import 'package:buzz/widgets/Geral/Text_Button.dart';
import 'package:buzz/models/usuario.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final String email = emailController.text;
      final String password = passwordController.text;

      print('Email: $email');
      print('Password: $password');

      print('Sending login request with email: $email and password: $password');
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/'),  // Verifique se a URL está correta
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      print('Response received. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String status = responseBody['status'];
        final int userTypeId = responseBody['user_type_id'];

        print('Login successful. User type ID: $userTypeId');
        if (status == 'success') {
          Usuario usuario;

          switch (userTypeId) {
            case 1:
              usuario = Usuario(tipoUsuario: 'student');
              break;
            case 2:
              usuario = Usuario(tipoUsuario: 'driver');
              break;
            case 3:
              usuario = Usuario(tipoUsuario: 'admin');
              break;
            default:
              usuario = Usuario(tipoUsuario: 'unknown');
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(usuario: usuario)),
          );
        }
      } else {
        print('Falha na autenticação. Código de status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha na autenticação')),
        );
      }
    } catch (e) {
      print('Erro durante a autenticação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),  // Adiciona padding para melhor visualização
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
                    controller: emailController,
                  ),
                  SizedBox(height: 20),
                  CustomInputField(
                    labelText: 'Senha',
                    obscureText: true,
                    controller: passwordController,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Button_One(
              buttonText: 'Realizar Login',
              onPressed: _login,
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
