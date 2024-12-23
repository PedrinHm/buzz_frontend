import 'package:buzz/screens/Auth/login_screen.dart';
import 'package:buzz/widgets/Geral/Custom_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/config/config.dart';
// Widgets
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Button_One.dart';
import 'package:buzz/widgets/Geral/Text_Button.dart';
import 'package:buzz/utils/size_config.dart'; // Importa o arquivo de utilitários de tamanho
import 'package:buzz/widgets/Geral/Cpf_input_formatter.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController cpfController = TextEditingController();

  final cpfFormatter = CpfInputFormatter();

  Future<void> _sendResetPasswordRequest(BuildContext context) async {
    final cpf = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
    final url = '${Config.backendUrl}/auth/forgot-password';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cpf': cpf}),
      );

      if (response.statusCode == 200) {
        // Mostra um diálogo de sucesso usando CustomPopup
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            message:
                'Um e-mail foi enviado com instruções para redefinir sua senha.',
            confirmText: 'OK',
            cancelText: 'sair',
            onConfirm: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      } else {
        // Mostra um diálogo de erro usando CustomPopup
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            message: 'Falha ao enviar o e-mail de redefinição de senha.',
            confirmText: 'Ok',
            cancelText: 'sair',
            onConfirm: () {
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      }
    } catch (e) {
      // Mostra um diálogo de erro em caso de exceção usando CustomPopup
      showDialog(
        context: context,
        builder: (context) => CustomPopup(
          message:
              'Ocorreu um erro ao enviar o pedido de redefinição de senha. Tente novamente mais tarde.',
          confirmText: 'OK',
          cancelText: 'sair',
          onConfirm: () {
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(
            getHeightProportion(context, 16.0)), // Proporção em altura
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
                    hintText: 'Ex: 123.456.789-00',
                    inputFormatters: [cpfFormatter],
                  ),
                ],
              ),
            ),
            SizedBox(
                height:
                    getHeightProportion(context, 20)), // Proporção em altura
            Button_One(
              buttonText: 'Enviar para meu e-mail',
              onPressed: () {
                _sendResetPasswordRequest(
                    context); // Chama a função para enviar o CPF
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
