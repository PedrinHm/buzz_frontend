import 'package:buzz/models/usuario.dart';
import 'package:buzz/screens/Admin/form_screen.dart';
import 'package:buzz/widgets/Geral/Custom_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:buzz/utils/size_config.dart'; 
import 'package:buzz/config/config.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Usuario> _userFuture;
  String? _base64Image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.userId);
  }

  Future<Usuario> _fetchUser(int userId) async {
    final response = await http.get(Uri.parse('${Config.backendUrl}/users/$userId/with-picture'));

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      return Usuario.fromJson(json.decode(responseBody));
    } else {
      throw Exception('Failed to load user');
    }
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
              '${Config.backendUrl}/users/${widget.userId}/profile-picture'),
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => CustomPopup(
        message: 'Tem certeza de que deseja sair?',
        confirmText: 'Sim',
        cancelText: 'Não',
        onConfirm: () {
          Navigator.of(context).pop(); // Fechar o popup
          _logout(); // Executar o logout
        },
        onCancel: () {
          Navigator.of(context).pop(); // Apenas fechar o popup
        },
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _removeProfilePicture() async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${Config.backendUrl}/users/${widget.userId}/profile-picture'),
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

  Future<void> _editUserData(Usuario user) async {
    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';

    List<Map<String, dynamic>> fields = [
      {
        'label': 'Nome',
        'controller': _nameController,
        'keyboardType': TextInputType.name,
      },
      {
        'label': 'Email',
        'controller': _emailController,
        'keyboardType': TextInputType.emailAddress,
      },
    ];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(
          title: 'Editar Meus Dados',
          fields: fields,
          isEdit: true,
          id: widget.userId,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _userFuture = _fetchUser(widget.userId);
      });
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
          height: getHeightProportion(context, 811),
          padding: EdgeInsets.all(getHeightProportion(context, 20.0)),
          decoration: BoxDecoration(
            color: Color(0xFF395BC7),
            borderRadius: BorderRadius.circular(getHeightProportion(context, 10.0)),
          ),
          child: Stack(
            children: [
              Column(
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
                              context, 24),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.logout, color: Colors.white),
                            onPressed: _confirmLogout,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          getHeightProportion(context, 20)),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: getHeightProportion(context, 175),
                        height: getHeightProportion(context, 175),
                        decoration: BoxDecoration(
                          color: user.profilePicture == null ? Colors.grey[300] : null,
                          border: Border.all(
                            color: Colors.white,
                            width: getHeightProportion(context, 1),
                          ),
                          borderRadius: BorderRadius.circular(getHeightProportion(context, 10)),
                        ),
                        child: user.profilePicture != null
                            ? Image.memory(
                                base64Decode(user.profilePicture!),
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  user.name != null && user.name!.isNotEmpty
                                      ? user.name![0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: getHeightProportion(context, 60),
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height:
                          getHeightProportion(context, 20)),
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
                              context, 20)),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: _confirmDeleteProfilePicture,
                        tooltip: 'Remover Foto',
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          getHeightProportion(context, 20)),
                  _buildInfoColumn(_getLabel(user.tipoUsuario),
                      user.name ?? 'Nome não disponível'),
                  SizedBox(
                      height:
                          getHeightProportion(context, 20)),
                  _buildInfoColumn('E-mail', user.email ?? 'Email não disponível'),
                  SizedBox(
                      height:
                          getHeightProportion(context, 20)),
                  _buildInfoColumn('CPF', user.cpf ?? 'CPF não disponível'),
                  if (user.tipoUsuario == 'student') ...[
                    SizedBox(
                        height:
                            getHeightProportion(context, 20)),
                    _buildInfoColumn('Faculdade',
                        user.facultyName ?? 'Faculdade não disponível'),
                  ],
                ],
              ),
              if (user.tipoUsuario == 'admin')
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editUserData(user),
                    tooltip: 'Editar meus dados',
                  ),
                ),
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
            fontSize: getHeightProportion(context, 18),
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: getHeightProportion(context, 16),
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
