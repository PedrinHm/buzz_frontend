import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart'; // Certifique-se de importar isso também

class BuildOverlay extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onCancel;

  const BuildOverlay({
    Key? key,
    required this.title,
    required this.content,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.9), // Fundo semi-transparente
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: getHeightProportion(context, 40)), // Proporção para altura
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: getHeightProportion(context, 24), // Proporção para altura
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: getHeightProportion(context, 20)), // Proporção para altura
            Expanded(
              child: content, // O conteúdo que você passa para a função (lista de ônibus, status, etc.)
            ),
            Padding(
            padding: EdgeInsets.all(getHeightProportion(context, 20)), // Proporção para altura
            child: ButtonThree(
              buttonText: 'Cancelar',
              backgroundColor: Colors.red,
              onPressed: onCancel,
            ),
            ),
          ],
        ),
      ],
    );
  }
}
