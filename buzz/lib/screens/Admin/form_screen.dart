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
import 'package:flutter/services.dart';

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

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    
    // Remove tudo que não é dígito
    text = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limita a 11 dígitos
    if (text.length > 11) {
      text = text.substring(0, 11);
    }
    
    var newText = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) newText += '.';
      if (i == 9) newText += '-';
      newText += text[i];
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    
    // Remove tudo que não é dígito
    text = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limita a 11 dígitos (para celular) ou 10 dígitos (para fixo)
    if (text.length > 11) {
      text = text.substring(0, 11);
    }
    
    var newText = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 0) newText += '(';
      if (i == 2) newText += ') ';
      if (i == 7) newText += '-';  // Ajustado para a posição correta
      newText += text[i];
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
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
    
    // Formata os campos se estiver em modo de edição
    if (widget.isEdit) {
      for (var field in widget.fields) {
        if (field['label'] == 'CPF') {
          String cpf = field['controller'].text;
          if (cpf.length == 11) {
            field['controller'].text = '${cpf.substring(0,3)}.${cpf.substring(3,6)}.${cpf.substring(6,9)}-${cpf.substring(9)}';
          }
        }
        if (field['label'] == 'Telefone') {
          String phone = field['controller'].text;
          if (phone.length >= 10) {
            if (phone.length == 11) {
              field['controller'].text = '(${phone.substring(0,2)}) ${phone.substring(2,7)}-${phone.substring(7)}';
            } else {
              field['controller'].text = '(${phone.substring(0,2)}) ${phone.substring(2,6)}-${phone.substring(6)}';
            }
          }
        }
      }
    }

    // Código existente do initState
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
    // Adicionar validação de capacidade para o formulário de ônibus
    if (widget.title == 'Cadastro de Ônibus') {
      int? capacity = int.tryParse(widget.fields[2]['controller'].text);
      if (capacity == null || capacity < 1) {
        _showSnackbar('A capacidade deve ser maior que zero.', Colors.red);
        return;
      }
    }

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

    // Funço auxiliar para limpar máscaras
    String removeMask(String text) {
      return text.replaceAll(RegExp(r'[^\d]'), '');
    }

    switch (widget.title) {
      case 'Cadastro de Motorista':
        apiUrl = '${Config.backendUrl}/users/';
        if (widget.isEdit) {
          apiUrl += '${widget.id}';
        }
        body = {
          'name': widget.fields[0]['controller'].text,
          'email': widget.fields[1]['controller'].text,
          'cpf': removeMask(widget.fields[2]['controller'].text),
          'phone': removeMask(widget.fields[3]['controller'].text),
          'user_type_id': 2,
          'password': removeMask(widget.fields[2]['controller'].text),
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
          'cpf': removeMask(widget.fields[2]['controller'].text),
          'phone': removeMask(widget.fields[3]['controller'].text),
          'faculty_id': selectedFacultyId,
          'user_type_id': 1,
          'password': removeMask(widget.fields[2]['controller'].text),
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

  String _getHintText(String label) {
    switch (label) {
      case 'Nome':
        return 'Ex: João da Silva';
      case 'Email':
        return 'Ex: joao.silva@email.com';
      case 'CPF':
        return 'Ex: 123.456.789-00';
      case 'Telefone':
        return 'Ex: (43) 98765-4321';
      case 'Capacidade':
        return 'Ex: 45';

      case 'Placa':
        return 'Ex: ABC1234';
      case 'Nome do Ponto':
        return 'Ex: Ponto Terminal Central';
      case 'Nome da Faculdade':
        return 'Ex: Faculdade de Engenharia';
      default:
        return '';
    }
  }

  List<TextInputFormatter>? _getInputFormatters(String label) {
    switch (label) {
      case 'CPF':
        return [CpfInputFormatter()];
      case 'Telefone':
        return [PhoneInputFormatter()];
      default:
        return null;
    }
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
                      String hintText = _getHintText(field['label']);
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: getHeightProportion(
                                context, 20.0)), // Proporção em altura
                        child: CustomInputField(
                          labelText: "${field['label']} *",
                          keyboardType: field['keyboardType'],
                          controller: field['controller'],
                          enabled: field['label'] == 'Capacidade' || field['label'] == 'Placa' 
                              ? true 
                              : (field['enabled'] ?? true),
                          hintText: hintText,
                          inputFormatters: _getInputFormatters(field['label']),
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
                          hintText: 'Ex: Faculdade de Tecnologia',
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
