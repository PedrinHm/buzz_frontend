import 'package:flutter/material.dart';
import 'package:buzz/widgets/Driver/Bus_stop_status.dart';
import 'package:buzz/widgets/Driver/student_status.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverStudentActiveScreen extends StatelessWidget {
  final VoidCallback endTrip;
  final int tripId; 

  DriverStudentActiveScreen({required this.endTrip, required this.tripId});

  final List<Map<String, String>> busStops = [
    {'name': 'Ponto 1', 'status': 'Já passou'},
    {'name': 'Ponto 2', 'status': 'No ponto'},
    {'name': 'ponto 3', 'status': 'A caminho'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<List<Map<String, String>>>(
          future: fetchStudents(tripId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados.'));
            }

            var students = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CustomTitleWidget(title: 'Viagem Atual - Alunos'),
                SizedBox(height: 20),
                ..._buildBusStopSections(students),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBusStopSections(List<Map<String, String>> students) {
    List<Widget> sections = [];
    for (var stop in busStops) {
      sections.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          BusStopStatus(
            busStopName: stop['name']!,
            busStopStatus: stop['status']!,
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
          ),
          ...students
              .where((student) => student['busStop'] == stop['name'])
              .map((student) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: StudentStatus(
                      studentName: student['name']!,
                      studentStatus: student['status']!,
                      imagePath: student['imagePath']!,
                      busStopName: stop['name']!,
                    ),
                  ))
              .toList(),
        ],
      ));
    }
    return sections;
  }
}

Future<List<Map<String, String>>> fetchStudents(int tripId) async {
  var url = Uri.parse('http://127.0.0.1:8000/trips/$tripId/details');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => {
      'name': item['student_name'] as String,
      'status': item['student_status'] as String,
      'imagePath': 'assets/images/profilepic.jpeg',  // Assuming this path is correct
      'busStop': item['bus_stop_name'] as String,
    }).toList().cast<Map<String, String>>();  // Forçando o cast para List<Map<String, String>>
  } else {
    throw Exception('Failed to load student trip details');
  }
}
