import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomBusButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String busNumber;
  final String driverName;

  CustomBusButton({
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
        height: MediaQuery.of(context).size.height * (150 / 938), 
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Color(0xFF395BC7), 
          borderRadius: BorderRadius.circular(10), 
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15), 
              decoration: BoxDecoration( 
                shape: BoxShape.rectangle, 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white, 
                  width: 1, 
                ),
              ),
              child: Icon(
                PhosphorIcons.bus,
                color: Colors.white,
                size: 35, 
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Definir ônibus',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ônibus atual: $busNumber', 
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                Text(
                  driverName, 
                  style: TextStyle(
                    fontSize: 12,
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
