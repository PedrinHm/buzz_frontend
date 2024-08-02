import 'package:buzz/screens/Admin/admin_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Admin/Nav_Bar_Admin.dart';
import 'package:buzz/widgets/Admin/list_item.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListScreen extends StatefulWidget {
  final String title;

  ListScreen({required this.title});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, String>> items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    String apiUrl;
    switch (widget.title) {
      case 'Cadastro de Motorista':
        apiUrl = 'http://127.0.0.1:8000/users/?user_type_id=2';
        break;
      case 'Cadastro de Aluno':
        apiUrl = 'http://127.0.0.1:8000/users/?user_type_id=1';
        break;
      case 'Cadastro de Pontos de Ônibus':
        apiUrl = 'http://127.0.0.1:8000/bus_stops/';
        break;
      case 'Cadastro de Ônibus':
        apiUrl = 'http://127.0.0.1:8000/buses/';
        break;
      case 'Cadastro de Faculdades':
        apiUrl = 'http://127.0.0.1:8000/faculties/';
        break;
      default:
        setState(() {
          _isLoading = false;
        });
        return;
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        items = data.where((item) {
          if (widget.title == 'Cadastro de Motorista') {
            return item['user_type_id'] == 2;
          } else if (widget.title == 'Cadastro de Aluno') {
            return item['user_type_id'] == 1;
          } else {
            return true;
          }
        }).map<Map<String, String>>((item) {
          return {
            'primary': item['name'] ?? '',
            'secondary': item.containsKey('email') ? item['email'] : '',
          };
        }).toList();
        _isLoading = false;
      });
    } else {
      // Handle error
      print('Erro ao buscar itens: ${response.body}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddForm(BuildContext context) async {
    List<Map<String, dynamic>> fields;

    switch (widget.title) {
      case 'Cadastro de Motorista':
        fields = [
          {'label': 'Nome', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
          {'label': 'Email', 'keyboardType': TextInputType.emailAddress, 'controller': TextEditingController()},
          {'label': 'CPF', 'keyboardType': TextInputType.number, 'controller': TextEditingController()},
          {'label': 'Telefone', 'keyboardType': TextInputType.phone, 'controller': TextEditingController()},
        ];
        break;
      case 'Cadastro de Aluno':
        fields = [
          {'label': 'Nome', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
          {'label': 'Email', 'keyboardType': TextInputType.emailAddress, 'controller': TextEditingController()},
          {'label': 'CPF', 'keyboardType': TextInputType.number, 'controller': TextEditingController()},
          {'label': 'Telefone', 'keyboardType': TextInputType.phone, 'controller': TextEditingController()},
          {'label': 'Curso', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
          {'label': 'Faculdade', 'keyboardType': TextInputType.number, 'controller': TextEditingController()},
        ];
        break;
      case 'Cadastro de Pontos de Ônibus':
        fields = [
          {'label': 'Nome do Ponto', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
          {'label': 'Faculdade', 'keyboardType': TextInputType.number, 'controller': TextEditingController()},
        ];
        break;
      case 'Cadastro de Ônibus':
        fields = [
          {'label': 'Modelo', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
          {'label': 'Placa', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
          {'label': 'Capacidade', 'keyboardType': TextInputType.number, 'controller': TextEditingController()},
        ];
        break;
      case 'Cadastro de Faculdades':
        fields = [
          {'label': 'Nome da Faculdade', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
        ];
        break;
      default:
        fields = [];
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenericFormScreen(title: widget.title, fields: fields)),
    );

    if (result == true) {
      _fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          CustomTitleWidget(title: widget.title),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Center(
                        child: ListItem(
                          primaryText: item['primary']!,
                          secondaryText: item['secondary']!,
                          onEdit: () {
                            // Lógica para editar o item
                          },
                          onDelete: () {
                            // Lógica para excluir o item
                          },
                          index: index, // Passa o índice aqui
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddForm(context),
        backgroundColor: Color(0xFF395BC7),
        child: Icon(PhosphorIcons.plus, size: 30, color: Colors.white),
      ),
      bottomNavigationBar: NavBarAdmin(
        currentIndex: 1,
        onTap: (index) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
