import 'package:flutter/material.dart';
import 'package:buzz/widgets/Driver/Bus_stop_status.dart';
import 'package:buzz/widgets/Driver/student_status.dart';
import 'package:buzz/widgets/Geral/Title.dart';

class DriverTripScreen extends StatelessWidget {
  final List<Map<String, String>> busStops = [
    {'name': 'Ponto 1', 'status': 'Já passou'},
    {'name': 'Ponto 2', 'status': 'No ponto'},
    {'name': 'Ponto 3', 'status': 'A caminho'},
  ];

  final List<Map<String, String>> students = [
    {
      'name': 'Pedro Henrique Mendes',
      'status': 'Presente',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 1',
    },
     {
      'name': 'Pedro Henrique Mendes',
      'status': 'Presente',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 1',
    },
     {
      'name': 'Pedro Henrique Mendes',
      'status': 'Presente',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 1',
    },
    {
      'name': 'Pedro Henrique Mendes',
      'status': 'Em aula',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 2',
    },
     {
      'name': 'Pedro Henrique Mendes',
      'status': 'Presente',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 2',
    },
     {
      'name': 'Pedro Henrique Mendes',
      'status': 'Presente',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 3',
    },
    {
      'name': 'Pedro Henrique Mendes',
      'status': 'Aguardando ônibus',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 3',
    },
     {
      'name': 'Pedro Henrique Mendes',
      'status': 'Presente',
      'imagePath': 'assets/images/profliepic.jpeg',
      'busStop': 'Ponto 1',
    },
  ];

  List<Widget> _buildBusStopSections() {
    List<Widget> sections = [];
    for (var stop in busStops) {
      sections.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20), // Espaçamento acima do componente BusStopStatus
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CustomTitleWidget(title: 'Viagem Atual'),
            SizedBox(height: 20),
            ..._buildBusStopSections(),
          ],
        ),
      ),
    );
  }
}
