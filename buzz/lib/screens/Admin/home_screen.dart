import 'package:buzz/screens/Admin/list_screen.dart';
import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart';  // Importa o arquivo de utilitários de tamanho

class HomeScreen extends StatelessWidget {
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
            SizedBox(height: getHeightProportion(context, 20)),  // Proporção em altura
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
            SizedBox(height: getHeightProportion(context, 20)),  // Proporção em altura
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
            SizedBox(height: getHeightProportion(context, 20)),  // Proporção em altura
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
            SizedBox(height: getHeightProportion(context, 20)),  // Proporção em altura
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
          borderRadius: BorderRadius.circular(getWidthProportion(context, 10)),  // Proporção em largura para borda
        ),
        fixedSize: Size(
          getWidthProportion(context, 320),  // Proporção em largura
          getHeightProportion(context, 70),  // Proporção em altura
        ),
      ),
      child: Text(
        buttonText,  // Texto do botão passado como parâmetro
        style: TextStyle(
          fontSize: getHeightProportion(context, 16),  // Proporção em altura para o tamanho da fonte
          fontWeight: FontWeight.normal,  // Peso da fonte
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
