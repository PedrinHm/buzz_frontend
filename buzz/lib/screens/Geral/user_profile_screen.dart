import 'package:buzz/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Usuario> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.userId);
  }

  Future<Usuario> _fetchUser(int userId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/users/$userId'));

    if (response.statusCode == 200) {
      // Converte o JSON retornado em um objeto Usuario
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar os dados.'));
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return _buildUserProfile(user);
        } else {
          return Center(child: Text('Usuário não encontrado.'));
        }
      },
    );
  }

Widget _buildUserProfile(Usuario user) {
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
                  _getTitle(user.tipoUsuario),
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
                  child: user.profilePicture != null
                      ? Image.memory(
                          base64Decode(user.profilePicture!),
                          width: 175,
                          height: 175,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/default_profile.png',
                          width: 175,
                          height: 175,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildInfoColumn(_getLabel(user.tipoUsuario), user.name ?? 'Nome não disponível'),
            SizedBox(height: 20),
            _buildInfoColumn('E-mail', user.email ?? 'Email não disponível'),
            SizedBox(height: 20),
            _buildInfoColumn('CPF', user.cpf ?? 'CPF não disponível'),
            if (user.tipoUsuario == 'student') ...[
              SizedBox(height: 20),
              _buildInfoColumn('Curso', user.course ?? 'Curso não disponível'),
              SizedBox(height: 20),
              _buildInfoColumn('Faculdade', user.university ?? 'Faculdade não disponível'),
            ],
          ],
        ),
      ),
    ),
  );
}


  String _getTitle(String userType) {
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

  String _getLabel(String userType) {
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
