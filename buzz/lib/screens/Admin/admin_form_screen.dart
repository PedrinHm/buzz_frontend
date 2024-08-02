import 'package:buzz/widgets/Admin/Nav_Bar_Admin.dart';
import 'package:flutter/material.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:buzz/widgets/Geral/CustomDropdownField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenericFormScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> fields;
  final bool isEdit;
  final int? id;

  GenericFormScreen({required this.title, required this.fields, this.isEdit = false, this.id});

  @override
  _GenericFormScreenState createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  List<Map<String, dynamic>> faculties = [];
  int? selectedFacultyId;
  bool _isLoading = false;
  bool _isFacultyLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.title == 'Cadastro de Pontos de Ônibus' || widget.title == 'Cadastro de Aluno') {
      _fetchFaculties().then((_) {
        if (widget.isEdit) {
          selectedFacultyId = widget.fields.firstWhere((field) => field['label'] == 'Faculdade')['controller'].text.isNotEmpty
              ? int.parse(widget.fields.firstWhere((field) => field['label'] == 'Faculdade')['controller'].text)
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
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/faculties/'));

    if (response.statusCode == 200) {
      setState(() {
        faculties = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      // Handle error
      print('Erro ao buscar faculdades: ${response.body}');
    }
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    String apiUrl;
    Map<String, dynamic> body = {};

    switch (widget.title) {
      case 'Cadastro de Motorista':
        apiUrl = 'http://127.0.0.1:8000/users/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}/';
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
        apiUrl = 'http://127.0.0.1:8000/users/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}/';
        }
        body = {
          'name': widget.fields[0]['controller'].text,
          'email': widget.fields[1]['controller'].text,
          'cpf': widget.fields[2]['controller'].text,
          'phone': widget.fields[3]['controller'].text,
          'course': widget.fields[4]['controller'].text,
          'faculty_id': selectedFacultyId,
          'user_type_id': 1,
          'password': widget.fields[2]['controller'].text,
        };
        break;
      case 'Cadastro de Pontos de Ônibus':
        apiUrl = 'http://127.0.0.1:8000/bus_stops/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}/';
        }
        body = {
          'name': widget.fields[0]['controller'].text,
          'faculty_id': selectedFacultyId,
        };
        break;
      case 'Cadastro de Ônibus':
        apiUrl = 'http://127.0.0.1:8000/buses/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}/';
        }
        body = {
          'registration_number': widget.fields[1]['controller'].text,
          'name': widget.fields[0]['controller'].text,
          'capacity': int.tryParse(widget.fields[2]['controller'].text) ?? 0,
        };
        break;
      case 'Cadastro de Faculdades':
        apiUrl = 'http://127.0.0.1:8000/faculties/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}/';
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
      _showSnackbar(widget.isEdit ? 'Cadastro atualizado com sucesso!' : 'Cadastro realizado com sucesso!', Colors.green);
      Navigator.pop(context, true); // Retorna true para indicar que o cadastro foi bem-sucedido
    } else {
      _showSnackbar('Erro ao realizar o cadastro: ${response.body}', Colors.red);
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
        padding: const EdgeInsets.all(16.0),
        child: _isFacultyLoading || _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  CustomTitleWidget(title: widget.title),
                  SizedBox(height: 20),
                  ...widget.fields.where((field) => field['label'] != 'Faculdade').map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: CustomInputField(
                        labelText: field['label'],
                        keyboardType: field['keyboardType'],
                        controller: field['controller'],
                        enabled: field['enabled'] ?? true,
                      ),
                    );
                  }).toList(),
                  if (widget.title == 'Cadastro de Pontos de Ônibus' || widget.title == 'Cadastro de Aluno')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: CustomDropdownField(
                        labelText: 'Faculdade',
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
                  Spacer(),
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
                  SizedBox(height: 20),
                ],
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
