import 'package:buzz/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StatusButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String statusText;
  final Color color;
  final IconData icon;

  StatusButton({
    required this.onPressed,
    required this.statusText,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, 
          height: getHeightProportion(context, 100), // Altura proporcional
          padding: EdgeInsets.symmetric(
            vertical: getHeightProportion(context, 15.0), // Padding vertical proporcional
            horizontal: getWidthProportion(context, 20.0), // Padding horizontal proporcional
          ),
          decoration: BoxDecoration(
            color: color, // Usa a cor passada como parâmetro
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
                  icon,
                  color: Colors.white,
                  size: getWidthProportion(context, 35), // Tamanho proporcional do ícone
                ),
              ),
              SizedBox(width: getWidthProportion(context, 20)), // Espaço proporcional
              Text(
                statusText,
                style: TextStyle(
                  fontSize: getWidthProportion(context, 16), // Tamanho de fonte proporcional
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
