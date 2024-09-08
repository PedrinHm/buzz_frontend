import 'package:buzz/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Usuario> _userFuture;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.userId);
  }

  Future<Usuario> _fetchUser(int userId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/users/$userId'));

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Método para selecionar uma imagem e convertê-la para base64
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        print('Imagem selecionada: ${image.path}'); // Log para depuração
        final bytes = await image.readAsBytes(); // Usa abordagem assíncrona para leitura de bytes
        setState(() {
          _base64Image = base64Encode(bytes);
        });
        print('Imagem convertida para base64'); // Log para depuração
        await _uploadProfilePicture(); // Chama o método para enviar a imagem para a API
      } else {
        print('Nenhuma imagem selecionada.'); // Log para depuração
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e'); // Log para depuração de erro
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_base64Image != null) {
      try {
        print('Enviando imagem para API...'); // Log para depuração
        final response = await http.put(
          Uri.parse('http://127.0.0.1:8000/users/${widget.userId}/profile-picture'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'picture': _base64Image}),
        );

        if (response.statusCode == 200) {
          print('Foto de perfil atualizada com sucesso');
          setState(() {
            _userFuture = _fetchUser(widget.userId);
          });
        } else {
          print('Erro ao atualizar foto de perfil: ${response.statusCode}');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Erro'),
              content: Text('Não foi possível atualizar a foto de perfil.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print('Erro ao enviar imagem: $e'); // Log para depuração de erro
      }
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
                    onPressed: _logout,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage, // Seleciona a imagem
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
                              'images/default_profile.jpeg',
                              width: 175,
                              height: 175,
                              fit: BoxFit.cover,
                            ),
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
                _buildInfoColumn('Faculdade', user.facultyName ?? 'Faculdade não disponível'), // Atualizado para usar facultyName
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
