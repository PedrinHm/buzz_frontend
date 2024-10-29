import 'package:buzz/screens/Admin/form_screen.dart';
import 'package:buzz/utils/error_handling.dart';
import 'package:buzz/widgets/Geral/Custom_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Admin/Nav_Bar_Admin.dart';
import 'package:buzz/widgets/Admin/list_item.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/utils/size_config.dart'; // Importa o arquivo de utilitários de tamanho
import 'package:buzz/config/config.dart';
// Função utilitária para decodificar as respostas HTTP
dynamic decodeJsonResponse(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    return json.decode(responseBody);
  } else {
    throw Exception(
        'Failed to parse JSON, status code: ${response.statusCode}');
  }
}

class ListScreen extends StatefulWidget {
  final String title;

  ListScreen({required this.title});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  String _truncateText(String text, {int maxLength = 30}) {
    return text.length > maxLength
        ? text.substring(0, maxLength) + '...'
        : text;
  }


  @override
  void initState() {
    super.initState();
    _fetchItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    String apiUrl;
    switch (widget.title) {
      case 'Cadastro de Motorista':
        apiUrl = '${Config.backendUrl}/users/?user_type_id=2';
        break;
      case 'Cadastro de Aluno':
        apiUrl = '${Config.backendUrl}/users/?user_type_id=1';
        break;
      case 'Cadastro de Pontos de Ônibus':
        apiUrl = '${Config.backendUrl}/bus_stops/';
        break;
      case 'Cadastro de Ônibus':
        apiUrl = '${Config.backendUrl}/buses/';
        break;
      case 'Cadastro de Faculdades':
        apiUrl = '${Config.backendUrl}/faculties/';
        break;
      default:
        setState(() {
          _isLoading = false;
        });
        return;
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = decodeJsonResponse(response);

      if (widget.title == 'Cadastro de Pontos de Ônibus') {
        final facultiesResponse =
            await http.get(Uri.parse('${Config.backendUrl}/faculties/'));

        if (facultiesResponse.statusCode == 200) {
          final List<dynamic> facultiesData =
              decodeJsonResponse(facultiesResponse);

          final Map<int, String> facultyMap = {
            for (var faculty in facultiesData) faculty['id']: faculty['name']
          };

          setState(() {
            items = data
                .where((item) => item['system_deleted'] == 0)
                .map<Map<String, dynamic>>((item) {
              return {
                ...item,
                'faculty_name':
                    facultyMap[item['faculty_id']] ?? 'Faculdade não encontrada'
              };
            }).toList();
            filteredItems = items;
            _isLoading = false;
          });
        } else {
          print('Erro ao buscar faculdades: ${facultiesResponse.body}');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          items = data.where((item) {
            if (widget.title == 'Cadastro de Motorista') {
              return item['user_type_id'] == 2;
            } else if (widget.title == 'Cadastro de Aluno') {
              return item['user_type_id'] == 1;
            } else {
              return item['system_deleted'] == 0;
            }
          }).map<Map<String, dynamic>>((item) {
            return item as Map<String, dynamic>;
          }).toList();
          filteredItems = items;
          _isLoading = false;
        });
      }
    } else {
      print('Erro ao buscar itens: ${response.body}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        final query = _searchController.text.toLowerCase();
        return item['name'].toLowerCase().contains(query) ||
            (item['email'] != null &&
                item['email'].toLowerCase().contains(query));
      }).toList();
    });
  }

  void _navigateToAddForm(BuildContext context) async {
    List<Map<String, dynamic>> fields;

    switch (widget.title) {
      case 'Cadastro de Motorista':
        fields = [
          {
            'label': 'Nome',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(),
            'enabled': true
          },
          {
            'label': 'Email',
            'keyboardType': TextInputType.emailAddress,
            'controller': TextEditingController()
          },
          {
            'label': 'CPF',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(),
            'enabled': true
          },
          {
            'label': 'Telefone',
            'keyboardType': TextInputType.phone,
            'controller': TextEditingController()
          },
        ];
        break;
      case 'Cadastro de Aluno':
        fields = [
          {
            'label': 'Nome',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(),
            'enabled': true
          },
          {
            'label': 'Email',
            'keyboardType': TextInputType.emailAddress,
            'controller': TextEditingController()
          },
          {
            'label': 'CPF',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(),
            'enabled': true
          },
          {
            'label': 'Telefone',
            'keyboardType': TextInputType.phone,
            'controller': TextEditingController()
          },
          {
            'label': 'Faculdade',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(),
            'enabled': true 
          },
        ];
        break;
      case 'Cadastro de Pontos de Ônibus':
        fields = [
          {
            'label': 'Nome do Ponto',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController()
          },
          {
            'label': 'Faculdade',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController()
          },
        ];
        break;
      case 'Cadastro de Ônibus':
        fields = [
          {
            'label': 'Nome',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController()
          },
          {
            'label': 'Placa',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(),
            'enabled': true
          },
          {
            'label': 'Capacidade',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(),
            'enabled': true
          },
        ];
        break;
      case 'Cadastro de Faculdades':
        fields = [
          {
            'label': 'Nome da Faculdade',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController()
          },
        ];
        break;
      default:
        fields = [];
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              FormScreen(title: widget.title, fields: fields)),
    );

    if (result == true) {
      _fetchItems();
    }
  }

  void _navigateToEditForm(
      BuildContext context, Map<String, dynamic> item) async {
    List<Map<String, dynamic>> fields;

    switch (widget.title) {
      case 'Cadastro de Motorista':
        fields = [
          {
            'label': 'Nome',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(text: item['name'] ?? ''),
            'enabled': true
          },
          {
            'label': 'Email',
            'keyboardType': TextInputType.emailAddress,
            'controller': TextEditingController(text: item['email'] ?? '')
          },
          {
            'label': 'CPF',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(text: item['cpf'] ?? ''),
            'enabled': false
          },
          {
            'label': 'Telefone',
            'keyboardType': TextInputType.phone,
            'controller': TextEditingController(text: item['phone'] ?? '')
          },
        ];
        break;
      case 'Cadastro de Aluno':
        fields = [
          {
            'label': 'Nome',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(text: item['name'] ?? ''),
            'enabled': true
          },
          {
            'label': 'Email',
            'keyboardType': TextInputType.emailAddress,
            'controller': TextEditingController(text: item['email'] ?? '')
          },
          {
            'label': 'CPF',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(text: item['cpf'] ?? ''),
            'enabled': false
          },
          {
            'label': 'Telefone',
            'keyboardType': TextInputType.phone,
            'controller': TextEditingController(text: item['phone'] ?? '')
          },
          {
            'label': 'Faculdade',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(
                text: item['faculty_id'] != null
                    ? item['faculty_id'].toString()
                    : '')
          },
        ];
        break;
      case 'Cadastro de Pontos de Ônibus':
        fields = [
          {
            'label': 'Nome do Ponto',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(text: item['name'] ?? '')
          },
          {
            'label': 'Faculdade',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(
                text: item['faculty_id'] != null
                    ? item['faculty_id'].toString()
                    : '')
          },
        ];
        break;
      case 'Cadastro de Ônibus':
        fields = [
          {
            'label': 'Nome',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(text: item['name'] ?? '')
          },
          {
            'label': 'Placa',
            'keyboardType': TextInputType.text,
            'controller':
                TextEditingController(text: item['registration_number'] ?? ''),
            'enabled': false
          },
          {
            'label': 'Capacidade',
            'keyboardType': TextInputType.number,
            'controller': TextEditingController(
                text: item['capacity'] != null
                    ? item['capacity'].toString()
                    : ''),
            'enabled': false
          },
        ];
        break;
      case 'Cadastro de Faculdades':
        fields = [
          {
            'label': 'Nome da Faculdade',
            'keyboardType': TextInputType.text,
            'controller': TextEditingController(text: item['name'] ?? '')
          },
        ];
        break;
      default:
        fields = [];
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FormScreen(
              title: widget.title,
              fields: fields,
              isEdit: true,
              id: item['id'])),
    );

    if (result == true) {
      _fetchItems();
    }
  }

  Future<void> _deleteItem(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          message: 'Deseja realmente excluir este item?',
          confirmText: 'Sim',
          cancelText: 'Não',
          onConfirm: () async {
            String apiUrl;
            switch (widget.title) {
              case 'Cadastro de Motorista':
                apiUrl = '${Config.backendUrl}/users/$id';
                break;
              case 'Cadastro de Aluno':
                apiUrl = '${Config.backendUrl}/users/$id';
                break;
              case 'Cadastro de Pontos de Ônibus':
                apiUrl = '${Config.backendUrl}/bus_stops/$id';
                break;
              case 'Cadastro de Ônibus':
                apiUrl = '${Config.backendUrl}/buses/$id';
                break;
              case 'Cadastro de Faculdades':
                apiUrl = '${Config.backendUrl}/faculties/$id';
                break;
              default:
                return;
            }

            final response = await http.delete(Uri.parse(apiUrl));

            if (response.statusCode == 200) {
              _showSnackbar('Registro excluído com sucesso!', Colors.green);
              _fetchItems();
            } else {
            showErrorMessage(context, response.body);
            }

            Navigator.of(context).pop(); // Fecha o diálogo após a exclusão
          },
          onCancel: () {
            Navigator.of(context).pop(); // Fecha o diálogo sem excluir
          },
        );
      },
    );
  }

  void _showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: getHeightProportion(context, 40)),
          CustomTitleWidget(title: widget.title),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '', 
                suffixIcon: Icon(
                    Icons.search),
                filled: true,
                fillColor:
                    Colors.grey[200], 
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30.0), 
                  borderSide: BorderSide.none, 
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.only(
                      left: getHeightProportion(context, 16.0),
                      right: getHeightProportion(context, 16.0),
                      top: getHeightProportion(context, 16.0),
                      bottom: getHeightProportion(context, 80.0),
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      String secondaryText;
                      if (widget.title == 'Cadastro de Pontos de Ônibus') {
                        secondaryText =
                            item['faculty_name'] ?? 'Faculdade não encontrada';
                      } else if (widget.title == 'Cadastro de Ônibus') {
                        secondaryText = item['registration_number'] ??
                            'Placa não encontrada';
                      } else {
                        secondaryText = item['email'] ?? '';
                      }
                      return Center(
                        child: ListItem(
                          primaryText: _truncateText(item['name'] ?? ''),
                          secondaryText: _truncateText(secondaryText),
                          onEdit: () => _navigateToEditForm(context, item),
                          onDelete: () => _deleteItem(item['id']),
                          index: index,
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
