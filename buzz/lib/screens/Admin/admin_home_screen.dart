import 'package:buzz/screens/Admin/admin_list_screen.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AdminButtonTwo(
              buttonText: 'Cadastro de Motorista',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: 'Cadastro de Motorista',
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: 'Cadastro de Aluno',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: 'Cadastro de Aluno',
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: 'Cadastro de Pontos de Ônibus',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: 'Cadastro de Pontos de Ônibus',
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: 'Cadastro de Ônibus',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: 'Cadastro de Ônibus',
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: 'Cadastro de Faculdades',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: 'Cadastro de Faculdades',
                    ),
                  ),
                );
              },
            ),
            // Adicione mais botões para outras listas conforme necessário
          ],
        ),
      ),
    );
  }
}

class AdminButtonTwo extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  AdminButtonTwo({
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Ação do botão passada como parâmetro
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF395BC7),  // Cor de fundo do botão
        foregroundColor: Colors.white,       // Cor do texto e ícones
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),  // Arredondamento das bordas
        ),
        fixedSize: Size(320, 70),  // Tamanho fixo do botão (largura x altura)
      ),
      child: Text(
        buttonText,  // Texto do botão passado como parâmetro
        style: TextStyle(
          fontSize: 16,  // Tamanho do texto
          fontWeight: FontWeight.normal,  // Peso da fonte
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
