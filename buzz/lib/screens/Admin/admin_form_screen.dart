import 'package:flutter/material.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Geral/Input_Field.dart';
import 'package:buzz/widgets/Geral/Title.dart';

class GenericFormScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> fields;

  GenericFormScreen({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            CustomTitleWidget(title: title),
            SizedBox(height: 20),
            ...fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CustomInputField(
                  labelText: field['label'],
                  keyboardType: field['keyboardType'],
                  controller: field['controller'],
                ),
              );
            }).toList(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ButtonThree(
                  buttonText: 'Cancelar',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: Color(0xFFDD4425), // Cor de fundo passada como parâmetro
                ),
                ButtonThree(
                  buttonText: 'Salvar',
                  onPressed: () {
                    print('Salvar pressionado!');
                  },
                  backgroundColor: Color(0xFF395BC7), // Cor de fundo passada como parâmetro
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
