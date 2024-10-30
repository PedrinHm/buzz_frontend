import 'package:flutter/material.dart';
import 'package:buzz/widgets/Driver/Bus_stop_status.dart';
import 'package:buzz/widgets/Driver/student_status.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/utils/size_config.dart'; // Importar funções de tamanho
import 'package:buzz/config/config.dart';
import 'package:buzz/utils/error_handling.dart';

import '../../services/decodeJsonResponse.dart';

class StudentBusStopActiveScreen extends StatefulWidget {
  final VoidCallback endTrip;
  final int tripId;

  StudentBusStopActiveScreen({required this.endTrip, required this.tripId});

  @override
  _StudentBusStopActiveScreenState createState() =>
      _StudentBusStopActiveScreenState();
}

class _StudentBusStopActiveScreenState
    extends State<StudentBusStopActiveScreen> {
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
              showErrorMessage(context, json.encode({'detail': [{'msg': 'Erro ao carregar dados: ${snapshot.error}'}]}));
              return Center(child: Text('Erro ao carregar dados. Puxe para atualizar.'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nenhum dado encontrado.',
                      style: TextStyle(
                        color: Color(0xFF000000).withOpacity(0.70),
                        fontSize: getHeightProportion(context, 16), // Proporção ajustada
                      ),
                    ),
                  ],
                ),
              );
            }

            var students = (snapshot.data!['students'] as List)
                .map((item) => Map<String, String>.from(item))
                .toList();
            var busStops = (snapshot.data!['busStops'] as List)
                .map((item) => Map<String, String>.from(item))
                .toList();

            bool busIssue = snapshot.data!['bus_issue'] ?? false;

            busStops.sort(
                (a, b) => _compareBusStopStatus(a['status']!, b['status']!));
            students.sort(
                (a, b) => _compareStudentStatus(a['status']!, b['status']!));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height:
                        getHeightProportion(context, 40)), // Proporção ajustada
                CustomTitleWidget(title: 'Alunos e Pontos de Ônibus'),
                SizedBox(
                    height:
                        getHeightProportion(context, 20)), // Proporção ajustada
                Expanded(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (busStops.isEmpty && students.isEmpty)
                          Center(
                            child: Text(
                              'Nenhum ponto de ônibus ou aluno encontrado.',
                              style: TextStyle(
                                color: Color(0xFF000000).withOpacity(0.70),
                                fontSize: getHeightProportion(
                                    context, 16), // Proporção ajustada
                              ),
                            ),
                          )
                        else ...[
                          if (busStops.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(getHeightProportion(
                                    context, 8.0)), // Proporção ajustada
                                child: Text(
                                  'Nenhum ponto de ônibus encontrado.',
                                  style: TextStyle(
                                    color: Color(0xFF000000).withOpacity(0.70),
                                    fontSize: getHeightProportion(
                                        context, 16), // Proporção ajustada
                                  ),
                                ),
                              ),
                            ),
                          if (students.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(getHeightProportion(
                                    context, 8.0)), // Proporção ajustada
                                child: Text(
                                  'Nenhum aluno encontrado.',
                                  style: TextStyle(
                                    color: Color(0xFF000000).withOpacity(0.70),
                                    fontSize: getHeightProportion(
                                        context, 16), // Proporção ajustada
                                  ),
                                ),
                              ),
                            ),
                          if (busStops.isNotEmpty)
                            ..._buildBusStopSections(busStops, students),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBusStopSections(
      List<Map<String, String>> busStops, List<Map<String, String>> students) {
    List<Widget> sections = [];
    for (var stop in busStops) {
      if (stop['name'] == null || stop['status'] == null) continue;

      sections.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              height: getHeightProportion(context, 20)), // Proporção ajustada
          BusStopStatus(
            busStopName: stop['name'] ?? 'N/A',
            busStopStatus: stop['status'] ?? 'N/A',
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
          ),
          ...students
              .where((student) => student['busStop'] == stop['name'])
              .map((student) {
            if (student['name'] == null || student['status'] == null)
              return SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.symmetric(
                  vertical:
                      getHeightProportion(context, 5)), // Proporção ajustada
              child: StudentStatus(
                studentName: student['name'] ?? 'N/A',
                studentStatus: student['status'] ?? 'N/A',
                profilePictureBase64: student['profilePictureBase64'] ?? '',
                busStopName: stop['name']!,
                firstLetter: (student['name'] ?? '?')[0].toUpperCase(),
              ),
            );
          }).toList(),
        ],
      ));
    }
    return sections;
  }

  final Map<String, int> busStopStatusOrder = {
    'No ponto': 2,
    'Próximo ponto': 3,
    'A caminho': 1,
    'Já passou': 4,
    'Desembarque': 6,
    'Ônibus com problema': 5,
  };

  final Map<String, int> studentStatusOrder = {
    'Presente': 1,
    'Aguardando no ponto': 3,
    'Em aula': 2,
    'Não voltará': 4,
    'Fila de espera': 5
  };

  // Função de comparação para ordenar os pontos de ônibus
  int _compareBusStopStatus(String statusA, String statusB) {
    return (busStopStatusOrder[statusA] ?? 0)
        .compareTo(busStopStatusOrder[statusB] ?? 0);
  }

  // Função de comparação para ordenar os alunos
  int _compareStudentStatus(String statusA, String statusB) {
    return (studentStatusOrder[statusA] ?? 0)
        .compareTo(studentStatusOrder[statusB] ?? 0);
  }
}

Future<Map<String, dynamic>> fetchData(int tripId) async {
  try {
    var studentsFuture = fetchStudents(tripId);
    var busStopsFuture = fetchBusStops(tripId);
    var results = await Future.wait([studentsFuture, busStopsFuture]);

    var busStopsResult = results[1] as Map<String, dynamic>;

    return {
      'students': results[0],
      'busStops': busStopsResult['busStops'],
      'bus_issue': busStopsResult['bus_issue'],
    };
  } catch (e) {
    print("Erro ao buscar dados: $e");
    throw Exception(json.encode({'detail': [{'msg': 'Falha ao carregar dados da viagem'}]}));
  }
}

Future<List<Map<String, String>>> fetchStudents(int tripId) async {
  var url = Uri.parse('${Config.backendUrl}/trips/$tripId/details');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = decodeJsonResponse(response);

    return data
        .map((item) => Map<String, String>.from({
              'name': item['student_name'] as String? ?? '',
              'status': item['student_status'] as String? ?? '',
              'profilePictureBase64': item['profile_picture'] as String? ?? '',
              'busStop': item['bus_stop_name'] as String? ?? '',
            }))
        .toList();
  } else if (response.statusCode == 404) {
    print("Nenhum dado encontrado para o tripId: $tripId");
    return [];
  } else {
    print("Erro ao carregar os detalhes da viagem dos estudantes, status code: ${response.statusCode}");
    throw Exception(json.encode({'detail': [{'msg': 'Falha ao carregar detalhes da viagem dos estudantes'}]}));
  }
}

Future<Map<String, dynamic>> fetchBusStops(int tripId) async {
  var url = Uri.parse('${Config.backendUrl}/trips/$tripId/bus_stops');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var data = decodeJsonResponse(response);

    bool busIssue = data['bus_issue'] ?? false;

    List<Map<String, String>> busStops = (data['bus_stops'] as List).map((item) {
      String status = item['status'] as String? ?? 'N/A';
      if (busIssue && status != 'Já passou') {
        status = 'Ônibus com problema';
      }
      return {
        'name': item['name'] as String? ?? 'N/A',
        'status': status,
      };
    }).toList();

    return {
      'bus_issue': busIssue,
      'busStops': busStops,
    };
  } else if (response.statusCode == 404) {
    return {
      'bus_issue': false,
      'busStops': [],
    };
  } else {
    throw Exception(json.encode({'detail': [{'msg': 'Falha ao carregar detalhes dos pontos de ônibus'}]}));
  }
}
