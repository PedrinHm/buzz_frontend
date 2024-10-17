import 'package:flutter/material.dart';
import 'package:buzz/screens/Auth/forgot_password_screen.dart';
import 'package:buzz/screens/Auth/reset_password_screen.dart'; // Tela de redefinição de senha
import 'package:buzz/screens/main_screen.dart';
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Button_One.dart';
import 'package:buzz/widgets/Geral/Text_Button.dart';
import 'package:buzz/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:buzz/utils/size_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:buzz/config/config.dart';
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

      final response = await http.post(
        Uri.parse('${Config.backendUrl}/auth/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final String status = responseBody['status'];
      final int userTypeId = responseBody['user_type_id'];
      final int userId = responseBody['id'];

      if (status == 'first_login') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(userId: userId),
          ),
        );
      } else if (status == 'success') {
        Usuario usuario;

        switch (userTypeId) {
          case 1:
            usuario = Usuario(tipoUsuario: 'student', id: userId);
            break;
          case 2:
            usuario = Usuario(tipoUsuario: 'driver', id: userId);
            break;
          case 3:
            usuario = Usuario(tipoUsuario: 'admin', id: userId);
            break;
          default:
            usuario = Usuario(tipoUsuario: 'unknown', id: userId);
        }

        String? deviceToken = await _getDeviceToken();
        if (deviceToken != null) {
          await _atualizarDeviceToken(userId, deviceToken);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(usuario: usuario),
          ),
        );
      } else if (response.statusCode == 403) {
        setState(() {
          _lockoutEndTime = DateTime.now().add(Duration(minutes: 10));
          _errorMessage =
              'Você excedeu o limite de tentativas, tente novamente mais tarde';
          _startTimer();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});

      if (_lockoutEndTime != null && DateTime.now().isAfter(_lockoutEndTime!)) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          padding: EdgeInsets.all(getHeightProportion(context, 16.0)),
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
                    SizedBox(height: getHeightProportion(context, 20)),
                    CustomInputField(
                      labelText: 'Senha',
                      obscureText: true,
                      controller: passwordController,
                    ),
                    SizedBox(height: getHeightProportion(context, 20)),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: getHeightProportion(context, 10)),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_lockoutEndTime != null)
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: getHeightProportion(context, 10)),
                        child: Text(
                          'Você poderá tentar novamente em ${_formatTimeRemaining()}',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Button_One(
                      buttonText: 'Realizar Login',
                      onPressed: _isLoading ||
                              (_lockoutEndTime != null &&
                                  DateTime.now().isBefore(_lockoutEndTime!))
                          ? () {}
                          : _login,
                    ),
                    TextLinkButton(
                      text: 'Esqueceu a senha?',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _atualizarDeviceToken(int userId, String deviceToken) async {
    const url = '${Config.backendUrl}/auth/update-device-token';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'user_id': userId,
        'device_token': deviceToken,
      }),
    );

    if (response.statusCode == 200) {
      print('Token do dispositivo atualizado com sucesso no backend.');
    } else {
      print('Erro ao atualizar o token do dispositivo: ${response.body}');
    }
  }

  Future<String?> _getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? deviceToken = await messaging.getToken();
    print("Token do dispositivo: $deviceToken");
    return deviceToken;
  }
}
