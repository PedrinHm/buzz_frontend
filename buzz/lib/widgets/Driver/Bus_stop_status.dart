import 'package:flutter/material.dart';

class BusStopStatus extends StatelessWidget {
  final String busStopName;
  final String busStopStatus;

  BusStopStatus({
    required this.busStopName,
    required this.busStopStatus,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.90, // Máximo de 90% da largura da tela
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: _getColorFromStatus(busStopStatus),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              busStopName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 5),
          Text(
            '$busStopStatus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
