import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  final String imagePath;
  final String studentName;
  final String email;
  final String cpf;
  final String course;
  final String university;

  StudentProfileScreen({
    required this.imagePath,
    required this.studentName,
    required this.email,
    required this.cpf,
    required this.course,
    required this.university,
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
                  Center(
                    child: Text(
                      'Dados do Aluno',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
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
              _buildInfoColumn('Aluno', studentName),
              SizedBox(height: 20),
              _buildInfoColumn('E-mail', email),
              SizedBox(height: 20),
              _buildInfoColumn('CPF', cpf),
              SizedBox(height: 20),
              _buildInfoColumn('Curso', course),
              SizedBox(height: 20),
              _buildInfoColumn('Faculdade', university),
            ],
          ),
        ),
      ),
    );
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
            fontWeight: FontWeight.bold,
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

void main() {
  runApp(MaterialApp(
    home: StudentProfileScreen(
      imagePath: 'lib/assets/profliepic.jpeg', // Caminho correto da imagem
      studentName: 'Pedro Henrique Mendes',
      email: 'pedro@email.com',
      cpf: '111.111.111-00',
      course: 'Eng. Software',
      university: 'Universidade de Rio Verde',
    ),
  ));
}
