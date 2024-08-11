import 'package:flutter/material.dart';
import 'package:buzz/widgets/Driver/Bus_stop_status.dart';
import 'package:buzz/widgets/Driver/student_status.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverStudentActiveScreen extends StatefulWidget {
  final VoidCallback endTrip;
  final int tripId;

  DriverStudentActiveScreen({required this.endTrip, required this.tripId});

  @override
  _DriverStudentActiveScreenState createState() => _DriverStudentActiveScreenState();
}

class _DriverStudentActiveScreenState extends State<DriverStudentActiveScreen> {
  Future<Map<String, dynamic>>? _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = fetchData(widget.tripId);
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureData = fetchData(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
            }

            var students = snapshot.data!['students'] as List<Map<String, String>>;
            var busStops = snapshot.data!['busStops'] as List<Map<String, String>>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CustomTitleWidget(title: 'Viagem Atual - Alunos e Pontos de Ônibus'),
                SizedBox(height: 20),
                if (busStops.isEmpty && students.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Nenhum ponto de ônibus ou aluno encontrado.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                else ...[
                  if (busStops.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Nenhum ponto de ônibus encontrado.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  if (students.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Nenhum aluno encontrado.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  if (busStops.isNotEmpty)
                    ..._buildBusStopSections(busStops, students),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBusStopSections(List<Map<String, String>> busStops, List<Map<String, String>> students) {
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

Future<Map<String, dynamic>> fetchData(int tripId) async {
  try {
    var studentsFuture = fetchStudents(tripId);
    var busStopsFuture = fetchBusStops(tripId);
    var results = await Future.wait([studentsFuture, busStopsFuture]);
    return {
      'students': results[0],
      'busStops': results[1],
    };
  } catch (e) {
    return {
      'students': [],
      'busStops': [],
    };
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
      'imagePath': 'assets/images/profilepic.jpeg',  
      'busStop': item['bus_stop_name'] as String,
    }).toList().cast<Map<String, String>>();
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception('Failed to load student trip details');
  }
}

Future<List<Map<String, String>>> fetchBusStops(int tripId) async {
  var url = Uri.parse('http://127.0.0.1:8000/trips/$tripId/bus_stops');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => {
      'name': item['name'] as String,
      'status': item['status'] as String,
    }).toList().cast<Map<String, String>>();
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception('Failed to load bus stop details');
  }
}
