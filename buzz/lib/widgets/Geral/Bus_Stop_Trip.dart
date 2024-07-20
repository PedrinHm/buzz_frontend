import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TripBusStop extends StatelessWidget {
  final VoidCallback onPressed;
  final String busStopName;
  final String busStopStatus;

  TripBusStop({
    required this.onPressed,
    required this.busStopName,
    required this.busStopStatus,
  });

  // Função para obter a cor baseada no status
  Color _getColorFromStatus(String status) {
    switch (status) {
      case 'Já passou':
        return Color(0xFF838383);
      case 'No ponto':
        return Color(0xFF3E9B4F);
      case 'Proximo ponto':
        return Color(0xFF87B237);
      case 'A caminho':
        return Color(0xFFFFBA18);
      case 'Ônibus com problema':
        return Color(0xFFCBB427);
      default:
        return Color(0xFF395BC7); // Cor padrão
    }
  }

  // Função para obter o ícone baseado no status
  IconData _getIconFromStatus(String status) {
    switch (status) {
      case 'Já passou':
        return PhosphorIcons.check;
      case 'No ponto':
        return PhosphorIcons.mapPin;
      case 'Proximo ponto':
        return PhosphorIcons.arrowFatRight;
      case 'A caminho':
        return PhosphorIcons.arrowFatLinesRight;
      case 'Ônibus com problema':
        return PhosphorIcons.warning;
      default:
        return PhosphorIcons.mapPin; // Ícone padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: MediaQuery.of(context).size.height * (100 / 938),
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: _getColorFromStatus(busStopStatus), // Obtém a cor com base no status
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
                  _getIconFromStatus(busStopStatus), // Usa o ícone baseado no status
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
                    busStopName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    busStopStatus,
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
      ),
    );
  }
}
