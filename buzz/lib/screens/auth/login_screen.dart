import 'package:flutter/material.dart';
import 'package:buzz/screens/Auth/forgot_password_screen.dart';
import 'package:buzz/screens/main_screen.dart';
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Button_One.dart';
import 'package:buzz/widgets/Geral/Text_Button.dart';
import 'package:buzz/models/usuario.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import para usar Timer

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime? _lockoutEndTime;
  Timer? _timer;

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Informe seu email e senha.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String email = emailController.text;
      final String password = passwordController.text;

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
      } else if (response.statusCode == 403) {
        setState(() {
          _lockoutEndTime = DateTime.now().add(Duration(minutes: 10));
          _errorMessage = 'Você excedeu o limite de tentativas, tente novamente mais tarde';

          _startTimer(); // Inicia o cronômetro para atualizar a interface
        });
      } else {
        setState(() {
          _errorMessage = 'Verifique suas credenciais e tente novamente';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro durante a autenticação';
      });
      print('Erro durante a autenticação: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancela qualquer cronômetro existente

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});

      if (_lockoutEndTime != null && DateTime.now().isAfter(_lockoutEndTime!)) {
        _timer?.cancel(); // Cancela o cronômetro quando o tempo de bloqueio terminar
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o cronômetro ao descartar o widget
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _formatTimeRemaining() {
    final remaining = _lockoutEndTime!.difference(DateTime.now());
    return '${remaining.inMinutes} minutos e ${remaining.inSeconds % 60} segundos';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),  // Adiciona padding para melhor visualização
          child: _isLoading 
            ? CircularProgressIndicator()
            : Column(
              mainAxisSize: MainAxisSize.min,
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
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (_lockoutEndTime != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Você poderá tentar novamente em ${_formatTimeRemaining()}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Button_One(
                  buttonText: 'Realizar Login',
                  onPressed: _isLoading || (_lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!))
                    ? () {}  // função vazia quando desabilitado
                    : _login,
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
      ),
    );
  }
}
