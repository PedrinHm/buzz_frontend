import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/widgets/Geral/Input_Field.dart'; // Importando CustomInputField
import 'package:buzz/widgets/Geral/Button_One.dart'; // Importando Button_One
import 'package:buzz/utils/size_config.dart'; // Importando o SizeConfig
import 'package:buzz/screens/Auth/login_screen.dart'; // Importando a tela de login
import 'package:buzz/config/config.dart';
import 'package:buzz/utils/error_handling.dart'; // Adicione esta importação

class ResetPasswordScreen extends StatefulWidget {
  final int userId;
  ResetPasswordScreen({required this.userId});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _setNewPassword() async {
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos';
      });
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'As senhas não coincidem';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.backendUrl}/auth/set-new-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': widget.userId,
          'new_password': newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Exibir o Snackbar verde após a redefinição da senha
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Senha redefinida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Aguarda o tempo do Snackbar e redireciona para a tela de login
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Substituir o Snackbar vermelho pela função showErrorMessage
        showErrorMessage(context, response.body);
        setState(() {
          _errorMessage = 'Erro ao redefinir a senha';
        });
      }
    } catch (e) {
      // Substituir o Snackbar vermelho pela função showErrorMessage
      showErrorMessage(context, 'Erro durante a redefinição de senha');
      setState(() {
        _errorMessage = 'Erro durante a redefinição de senha';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(getHeightProportion(context, 16.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInputField(
                labelText: 'Nova Senha',
                obscureText: true,
                controller: newPasswordController,
              ),
              SizedBox(height: getHeightProportion(context, 20)),
              CustomInputField(
                labelText: 'Confirmar Nova Senha',
                obscureText: true,
                controller: confirmPasswordController,
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding:
                      EdgeInsets.only(top: getHeightProportion(context, 10)),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: getHeightProportion(context, 20)),
              _isLoading
                  ? CircularProgressIndicator()
                  : Button_One(
                      buttonText: 'Definir Senha',
                      onPressed: () async {
                        await _setNewPassword(); // Função assíncrona chamada dentro de uma função anônima
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
