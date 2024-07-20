import 'package:buzz/models/list_data.dart';
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
              buttonText: listData[0].title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: listData[0].title,
                      items: listData[0].items,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: listData[1].title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: listData[1].title,
                      items: listData[1].items,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: listData[2].title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: listData[2].title,
                      items: listData[2].items,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: listData[3].title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: listData[3].title,
                      items: listData[3].items,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AdminButtonTwo(
              buttonText: listData[4].title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(
                      title: listData[4].title,
                      items: listData[4].items,
                    ),
                  ),
                );
              },
            ),
            // Adicione mais botões para outras listas
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
