import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:buzz/utils/size_config.dart'; // Import das funções de proporção

class StudentStatus extends StatelessWidget {
  final String studentName;
  final String studentStatus;
  final String profilePictureBase64;
  final String busStopName;

  StudentStatus({
    required this.studentName,
    required this.studentStatus,
    required this.profilePictureBase64,
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

  Widget _buildUserProfileImage(String profilePictureBase64, BuildContext context) {
    if (profilePictureBase64.isNotEmpty) {
      try {
        // Tenta decodificar a imagem de base64
        final decodedBytes = base64Decode(profilePictureBase64);
        return CircleAvatar(
          radius: getWidthProportion(context, 25), // Aplicando proporção
          backgroundImage: MemoryImage(decodedBytes),
        );
      } catch (e) {
        // Caso haja um erro na decodificação, usa a imagem padrão
        return CircleAvatar(
          radius: getWidthProportion(context, 25), // Aplicando proporção
          backgroundImage: AssetImage('assets/images/default_profile.jpeg'),
        );
      }
    } else {
      // Usa a imagem padrão se o caminho da imagem estiver vazio
      return CircleAvatar(
        radius: getWidthProportion(context, 25), // Aplicando proporção
        backgroundImage: AssetImage('assets/images/default_profile.jpeg'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,// Proporção da largura
      padding: EdgeInsets.symmetric(
        vertical: getHeightProportion(context, 10), // Proporção em altura
        horizontal: getWidthProportion(context, 20), // Proporção em largura
      ),
      decoration: BoxDecoration(
        color: _getColorFromStatus(studentStatus),
        borderRadius: BorderRadius.circular(getWidthProportion(context, 10)), // Proporção do raio
      ),
      child: Row(
        children: [
          _buildUserProfileImage(profilePictureBase64, context), // Passando o context para a função
          SizedBox(width: getWidthProportion(context, 10)), // Proporção em largura
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getHeightProportion(context, 14), // Proporção em altura
                ),
              ),
              Text(
                studentStatus,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getHeightProportion(context, 14), // Proporção em altura
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
