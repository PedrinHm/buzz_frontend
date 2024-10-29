import 'package:buzz/utils/error_handling.dart';
import 'package:buzz/widgets/Admin/Nav_Bar_Admin.dart';
import 'package:flutter/material.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:buzz/widgets/Geral/CustomDropdownField.dart';
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

class FormScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> fields;
  final bool isEdit;
  final int? id;

  FormScreen(
      {required this.title,
      required this.fields,
      this.isEdit = false,
      this.id});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  List<Map<String, dynamic>> faculties = [];
  int? selectedFacultyId;
  bool _isLoading = false;
  bool _isFacultyLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.title == 'Cadastro de Pontos de Ônibus' ||
        widget.title == 'Cadastro de Aluno') {
      _fetchFaculties().then((_) {
        if (widget.isEdit) {
          selectedFacultyId = widget.fields
                  .firstWhere(
                      (field) => field['label'] == 'Faculdade')['controller']
                  .text
                  .isNotEmpty
              ? int.parse(widget.fields
                  .firstWhere(
                      (field) => field['label'] == 'Faculdade')['controller']
                  .text)
              : null;
        }
        setState(() {
          _isFacultyLoading = false;
        });
      });
    } else {
      _isFacultyLoading = false;
    }
  }

  Future<void> _fetchFaculties() async {
    final response =
        await http.get(Uri.parse('${Config.backendUrl}/faculties/'));

    if (response.statusCode == 200) {
      setState(() {
        faculties =
            List<Map<String, dynamic>>.from(decodeJsonResponse(response));
      });
    } else {
      // Handle error
      print('Erro ao buscar faculdades: ${response.body}');
    }
  }

  Future<void> _saveForm() async {
    // Verifica se algum campo está vazio, exceto o campo Faculdade
    for (var field in widget.fields.where((field) => field['label'] != 'Faculdade')) {
      if (field['controller'].text.isEmpty) {
        _showSnackbar('O campo "${field['label']}" deve ser preenchido.', Colors.red);
        return;
      }
    }

    // Verifica a seleção da faculdade separadamente para os formulários relevantes
    if ((widget.title == 'Cadastro de Pontos de Ônibus' || 
         widget.title == 'Cadastro de Aluno') && 
        selectedFacultyId == null) {
      _showSnackbar('O campo "Faculdade" deve ser preenchido.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String apiUrl;
    Map<String, dynamic> body = {};

    switch (widget.title) {
      case 'Cadastro de Motorista':
        apiUrl = '${Config.backendUrl}/users/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}';
        }
        body = {
          'name': widget.fields[0]['controller'].text,
          'email': widget.fields[1]['controller'].text,
          'cpf': widget.fields[2]['controller'].text,
          'phone': widget.fields[3]['controller'].text,
          'user_type_id': 2,
          'password': widget.fields[2]['controller'].text,
        };
        break;
      case 'Cadastro de Aluno':
        apiUrl = '${Config.backendUrl}/users/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}';
        }

        if (selectedFacultyId == null) {
          showSnackbar(context, 'Selecione uma faculdade.', Colors.red);
          setState(() {
            _isLoading = false;
          });
          return;
        }

        body = {
          'name': widget.fields[0]['controller'].text,
          'email': widget.fields[1]['controller'].text,
          'cpf': widget.fields[2]['controller'].text,
          'phone': widget.fields[3]['controller'].text,
          'faculty_id': selectedFacultyId,
          'user_type_id': 1,
          'password': widget.fields[2]['controller'].text,
        };
        break;

      case 'Cadastro de Pontos de Ônibus':
        apiUrl = '${Config.backendUrl}/bus_stops/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}';
        }
        body = {
          'name': widget.fields[0]['controller'].text,
          'faculty_id': selectedFacultyId,
        };
        break;
      case 'Cadastro de Ônibus':
        apiUrl = '${Config.backendUrl}/buses/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}';
        }
        body = {
          'registration_number': widget.fields[1]['controller'].text,
          'name': widget.fields[0]['controller'].text,
          'capacity': int.tryParse(widget.fields[2]['controller'].text) ?? 0,
        };
        break;
      case 'Cadastro de Faculdades':
        apiUrl = '${Config.backendUrl}/faculties/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}';
        }
        body = {
          'name': widget.fields[0]['controller'].text,
        };
        break;
      default:
        setState(() {
          _isLoading = false;
        });
        return;
    }

    final response = await (widget.isEdit
        ? http.put(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          )
        : http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          ));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSnackbar(
          context,
          widget.isEdit
              ? 'Cadastro atualizado com sucesso!'
              : 'Cadastro realizado com sucesso!',
          Colors.green);
      Navigator.pop(context, true);
    } else {
      try {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final errorData = json.decode(decodedResponse);
        
        if (errorData['detail'] is List) {
          // Extrair apenas a mensagem de erro, removendo "Value error, "
          String errorMessage = errorData['detail'][0]['msg'];
          errorMessage = errorMessage.replaceAll('Value error, ', '');
          showSnackbar(context, errorMessage, Colors.red);
        } else {
          // Se detail é uma string direta
          showSnackbar(context, errorData['detail'], Colors.red);
        }
      } catch (e) {
        showSnackbar(context, 'Erro ao processar a resposta do servidor', Colors.red);
      }
    }
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
      body: Padding(
        padding: EdgeInsets.all(getHeightProportion(context, 16.0)),
        child: _isFacultyLoading || _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: getHeightProportion(
                            context, 40)), // Proporção em altura
                    CustomTitleWidget(title: widget.title),
                    SizedBox(
                        height: getHeightProportion(
                            context, 20)), // Proporção em altura
                    ...widget.fields.where((field) => field['label'] != 'Faculdade').map((field) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: getHeightProportion(
                                context, 20.0)), // Proporção em altura
                        child: CustomInputField(
                          labelText: "${field['label']} *",
                          keyboardType: field['keyboardType'],
                          controller: field['controller'],
                          enabled: field['label'] == 'Capacidade' ? true : (field['enabled'] ?? true),
                        ),
                      );
                    }).toList(),
                    if (widget.title == 'Cadastro de Pontos de Ônibus' ||
                        widget.title == 'Cadastro de Aluno')
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: getHeightProportion(
                                context, 20.0)), // Proporção em altura
                        child: CustomDropdownField(
                          labelText: 'Faculdade *',
                          value: selectedFacultyId,
                          items: faculties.map((faculty) {
                            return DropdownMenuItem<int>(
                              value: faculty['id'],
                              child: Text(faculty['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFacultyId = value;
                            });
                          },
                        ),
                      ),
                    SizedBox(
                        height: getHeightProportion(context,
                            20)), // Espaço extra para ajustar a rolagem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ButtonThree(
                          buttonText: 'Cancelar',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          backgroundColor: Color(0xFFDD4425),
                        ),
                        ButtonThree(
                          buttonText: 'Salvar',
                          onPressed: _saveForm,
                          backgroundColor: Color(0xFF395BC7),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: getHeightProportion(
                            context, 20)), // Proporção em altura
                  ],
                ),
              ),
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
