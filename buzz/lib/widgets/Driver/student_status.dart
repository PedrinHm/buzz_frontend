import 'package:flutter/material.dart';

class StudentStatus extends StatelessWidget {
  final String studentName;
  final String studentStatus;
  final String imagePath;
  final String busStopName;

  StudentStatus({
    required this.studentName,
    required this.studentStatus,
    required this.imagePath,
    required this.busStopName,
  });

  Color _getColorFromStatus(String status) {
    switch (status) {
      case 'Presente':
        return Color(0xFF3E9B4F);
      case 'Não voltará':
        return Color(0xFFFFBA18);
      case 'Aguardando ônibus':
        return Color(0xFF93C03F);
      case 'Em aula':
        return Color(0xFF395BC7);
      case 'Na fila de espera':
        return Color(0xFFA5921E);
      default:
        return Color(0xFF395BC7); // Cor padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90, // Ocupa 90% da largura da tela
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: _getColorFromStatus(studentStatus),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                studentStatus,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
