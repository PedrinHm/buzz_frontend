import 'package:buzz/models/usuario.dart';
import 'package:buzz/services/decodeJsonResponse.dart';
import 'package:buzz/widgets/Geral/Custom_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:buzz/utils/size_config.dart'; // Importar funções de tamanho

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
    final response = await http.get(Uri.parse(
        'https://buzzbackend-production.up.railway.app/users/$userId'));

    if (response.statusCode == 200) {
      return Usuario.fromJson(decodeJsonResponse(response));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
        await _uploadProfilePicture();
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_base64Image != null) {
      try {
        final response = await http.put(
          Uri.parse(
              'https://buzzbackend-production.up.railway.app/users/${widget.userId}/profile-picture'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'picture': _base64Image}),
        );

        if (response.statusCode == 200) {
          setState(() {
            _userFuture = _fetchUser(widget.userId);
          });
        } else {
          _showErrorDialog('Não foi possível atualizar a foto de perfil.');
        }
      } catch (e) {
        print('Erro ao enviar imagem: $e');
      }
    }
  }

  void _confirmDeleteProfilePicture() {
    showDialog(
      context: context,
      builder: (context) => CustomPopup(
        message: 'Tem certeza de que deseja remover a foto de perfil?',
        confirmText: 'Sim',
        cancelText: 'Não',
        onConfirm: () {
          Navigator.of(context).pop(); // Fecha o popup
          _removeProfilePicture(); // Executa a remoção da imagem
        },
        onCancel: () {
          Navigator.of(context).pop(); // Apenas fecha o popup
        },
      ),
    );
  }

  Future<void> _removeProfilePicture() async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://buzzbackend-production.up.railway.app/users/${widget.userId}/profile-picture'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _base64Image = null;
          _userFuture = _fetchUser(widget.userId);
        });
      } else {
        _showErrorDialog('Não foi possível remover a foto de perfil.');
      }
    } catch (e) {
      print('Erro ao remover imagem: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
          height: getHeightProportion(context, 811), // Proporção ajustada
          padding: EdgeInsets.all(
              getHeightProportion(context, 20.0)), // Proporção ajustada
          decoration: BoxDecoration(
            color: Color(0xFF395BC7),
            borderRadius: BorderRadius.circular(
                getHeightProportion(context, 10.0)), // Proporção ajustada
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
                      fontSize: getHeightProportion(
                          context, 24), // Proporção ajustada
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
              SizedBox(
                  height:
                      getHeightProportion(context, 20)), // Proporção ajustada
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white,
                          width: getHeightProportion(
                              context, 1)), // Proporção ajustada
                      borderRadius: BorderRadius.circular(getHeightProportion(
                          context, 10)), // Proporção ajustada
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(getHeightProportion(
                          context, 10)), // Proporção ajustada
                      child: user.profilePicture != null
                          ? Image.memory(
                              base64Decode(user.profilePicture!),
                              width: getHeightProportion(
                                  context, 175), // Proporção ajustada
                              height: getHeightProportion(
                                  context, 175), // Proporção ajustada
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/default_profile.jpeg',
                              width: getHeightProportion(
                                  context, 175), // Proporção ajustada
                              height: getHeightProportion(
                                  context, 175), // Proporção ajustada
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height:
                      getHeightProportion(context, 20)), // Proporção ajustada
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_a_photo, color: Colors.white),
                    onPressed: _pickImage,
                    tooltip: 'Adicionar Foto',
                  ),
                  SizedBox(
                      width: getHeightProportion(
                          context, 20)), // Proporção ajustada
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: _confirmDeleteProfilePicture,
                    tooltip: 'Remover Foto',
                  ),
                ],
              ),
              SizedBox(
                  height:
                      getHeightProportion(context, 20)), // Proporção ajustada
              _buildInfoColumn(_getLabel(user.tipoUsuario),
                  user.name ?? 'Nome não disponível'),
              SizedBox(
                  height:
                      getHeightProportion(context, 20)), // Proporção ajustada
              _buildInfoColumn('E-mail', user.email ?? 'Email não disponível'),
              SizedBox(
                  height:
                      getHeightProportion(context, 20)), // Proporção ajustada
              _buildInfoColumn('CPF', user.cpf ?? 'CPF não disponível'),
              if (user.tipoUsuario == 'student') ...[
                SizedBox(
                    height:
                        getHeightProportion(context, 20)), // Proporção ajustada
                _buildInfoColumn('Faculdade',
                    user.facultyName ?? 'Faculdade não disponível'),
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
            fontSize: getHeightProportion(context, 18), // Proporção ajustada
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: getHeightProportion(context, 16), // Proporção ajustada
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
