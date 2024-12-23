import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/utils/size_config.dart';  // Import correto

class CustomBusInfoButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String busNumber;
  final String driverName;

  CustomBusInfoButton({
    required this.onPressed,
    required this.busNumber,
    required this.driverName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: getHeightProportion(context, 100),  // Proporção de altura
        padding: EdgeInsets.symmetric(
          vertical: getHeightProportion(context, 10.0), 
          horizontal: getWidthProportion(context, 20.0), // Proporção de padding
        ),
        decoration: BoxDecoration(
          color: Color(0xFF395BC7),
          borderRadius: BorderRadius.circular(getHeightProportion(context, 10)), // Proporção de borda
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(getHeightProportion(context, 10)),  // Proporção de padding
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(getHeightProportion(context, 10)), // Proporção de borda
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Icon(
                PhosphorIcons.bus,
                color: Colors.white,
                size: getHeightProportion(context, 35),  // Tamanho do ícone proporcional
              ),
            ),
            SizedBox(width: getWidthProportion(context, 20)),  // Proporção de espaçamento
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Definir ônibus',
                  style: TextStyle(
                    fontSize: getHeightProportion(context, 16),  // Tamanho do texto proporcional
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ônibus atual: $busNumber',
                  style: TextStyle(
                    fontSize: getHeightProportion(context, 12),  // Tamanho do texto proporcional
                    color: Colors.white,
                  ),
                ),
                Text(
                  driverName,
                  style: TextStyle(
                    fontSize: getHeightProportion(context, 12),  // Tamanho do texto proporcional
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
