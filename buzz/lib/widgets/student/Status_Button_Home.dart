import 'package:buzz/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomStatus extends StatelessWidget {
  final VoidCallback onPressed;
  final String StatusName;
  final IconData iconData; // Adiciona um campo para o ícone

  CustomStatus({
    required this.onPressed,
    required this.StatusName,
    required this.iconData, // Passa o ícone como parâmetro
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, 
        height: getHeightProportion(context, 100), // Altura proporcional
        padding: EdgeInsets.symmetric(vertical: getHeightProportion(context, 15.0), horizontal: getWidthProportion(context, 20.0)), // Padding proporcional
        decoration: BoxDecoration(
          color: Color(0xFF395BC7), 
          borderRadius: BorderRadius.circular(10), 
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(getHeightProportion(context, 15)), // Padding proporcional
              decoration: BoxDecoration( 
                shape: BoxShape.rectangle, 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white, 
                  width: 1, 
                ),
              ),
              child: Icon(
                iconData, // Usa o ícone passado como parâmetro
                color: Colors.white,
                size: getWidthProportion(context, 35), // Tamanho proporcional
              ),
            ),
            SizedBox(width: getWidthProportion(context, 20)), // Espaço proporcional
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Definir Status',
                  style: TextStyle(
                    fontSize: getWidthProportion(context, 16), // Tamanho de fonte proporcional
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Status atual: $StatusName', 
                  style: TextStyle(
                    fontSize: getWidthProportion(context, 12), // Tamanho de fonte proporcional
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
