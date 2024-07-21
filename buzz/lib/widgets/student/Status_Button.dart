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
          width: MediaQuery.of(context).size.width * 0.9, // Define 90% da largura da tela
          height: 100, // Altura fixa de 70px
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: color, // Usa a cor passada como parâmetro
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
                  icon,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              SizedBox(width: 20),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
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
