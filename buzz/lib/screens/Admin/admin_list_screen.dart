import 'package:buzz/screens/Admin/form_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Admin/Nav_Bar_Admin.dart';
import 'package:buzz/widgets/Admin/list_item.dart';
import 'package:buzz/widgets/Geral/Title.dart';


class ListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  ListScreen({required this.title, required this.items});

  void _navigateToAddForm(BuildContext context) {
    List<Map<String, dynamic>> fields;

    switch (title) {
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
          {'label': 'Faculdade', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
        ];
        break;
      case 'Cadastro de Pontos de Ônibus':
        fields = [
          {'label': 'Nome do Ponto', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
          {'label': 'Faculdade', 'keyboardType': TextInputType.text, 'controller': TextEditingController()},
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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenericFormScreen(title: title, fields: fields)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40), // Espaço antes do título
          CustomTitleWidget(title: title),
          Expanded(
            child: ListView.builder(
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
          // Lógica de navegação para a tela inicial do admin
          Navigator.pop(context); // Volta para a tela anterior (AdminHomeScreen)
        },
      ),
    );
  }
}
