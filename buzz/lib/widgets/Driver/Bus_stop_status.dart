import 'package:flutter/material.dart';
import 'package:buzz/utils/size_config.dart'; // Import das funções de proporção

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
        maxWidth: MediaQuery.of(context).size.width * 0.90,  // Máximo de 90% da largura da tela proporcional
      ),
      padding: EdgeInsets.symmetric(
        vertical: getHeightProportion(context, 5), // Proporção em altura
        horizontal: getWidthProportion(context, 10), // Proporção em largura
      ),
      decoration: BoxDecoration(
        color: _getColorFromStatus(busStopStatus),
        borderRadius: BorderRadius.circular(getWidthProportion(context, 10)), // Proporção em largura
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              busStopName,
              style: TextStyle(
                color: Colors.white,
                fontSize: getHeightProportion(context, 14), // Proporção em altura
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: getWidthProportion(context, 5)), // Proporção em largura
          Text(
            '$busStopStatus',
            style: TextStyle(
              color: Colors.white,
              fontSize: getHeightProportion(context, 14), // Proporção em altura
            ),
          ),
        ],
      ),
    );
  }
}
