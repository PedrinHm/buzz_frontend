import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String imagePath;
  final String name;
  final String email;
  final String cpf;
  final String userType; // "admin", "driver", or "student"
  final String? course;
  final String? university;

  UserProfileScreen({
    required this.imagePath,
    required this.name,
    required this.email,
    required this.cpf,
    required this.userType,
    this.course,
    this.university,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * (811 / 932),
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Color(0xFF395BC7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTitle(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      // Adicione aqui a lógica de logout
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      width: 175,
                      height: 175,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildInfoColumn(_getLabel(), name),
              SizedBox(height: 20),
              _buildInfoColumn('E-mail', email),
              SizedBox(height: 20),
              _buildInfoColumn('CPF', cpf),
              if (userType == 'student') ...[
                SizedBox(height: 20),
                _buildInfoColumn('Curso', course ?? ''),
                SizedBox(height: 20),
                _buildInfoColumn('Faculdade', university ?? ''),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (userType) {
      case 'admin':
        return 'Dados do Administrador';
      case 'driver':
        return 'Dados do Motorista';
      case 'student':
        return 'Dados do Aluno';
      default:
        return 'Perfil';
    }
  }

  String _getLabel() {
    switch (userType) {
      case 'admin':
        return 'Admin';
      case 'driver':
        return 'Motorista';
      case 'student':
        return 'Aluno';
      default:
        return 'Usuário';
    }
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
