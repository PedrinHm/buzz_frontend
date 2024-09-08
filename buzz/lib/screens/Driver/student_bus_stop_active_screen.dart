import 'package:flutter/material.dart';
import 'package:buzz/widgets/Driver/Bus_stop_status.dart';
import 'package:buzz/widgets/Driver/student_status.dart';
import 'package:buzz/widgets/Geral/Title.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Função utilitária para decodificar as respostas HTTP
dynamic decodeJsonResponse(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    return json.decode(responseBody);
  } else {
    throw Exception('Failed to parse JSON, status code: ${response.statusCode}');
  }
}

class StudentBusStopActiveScreen extends StatefulWidget {
  final VoidCallback endTrip;
  final int tripId;

  StudentBusStopActiveScreen({required this.endTrip, required this.tripId});

  @override
  _StudentBusStopActiveScreenState createState() => _StudentBusStopActiveScreenState();
}

class _StudentBusStopActiveScreenState extends State<StudentBusStopActiveScreen> {
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

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('Nenhum dado encontrado.'));
            }

            // Convertendo explicitamente para List<Map<String, String>>
            var students = (snapshot.data!['students'] as List)
                .map((item) => Map<String, String>.from(item))
                .toList();
            var busStops = (snapshot.data!['busStops'] as List)
                .map((item) => Map<String, String>.from(item))
                .toList();

            // Ordenando e filtrando os dados antes de exibir
            busStops.sort((a, b) => _compareBusStopStatus(a['status']!, b['status']!));
            students = students
                .where((student) => student['status'] != 'Fila de espera')
                .toList();
            students.sort((a, b) => _compareStudentStatus(a['status']!, b['status']!));

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
                        style: TextStyle(
                          color: Color(0xFF000000).withOpacity(0.70),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else ...[
                  if (busStops.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Nenhum ponto de ônibus encontrado.',
                        style: TextStyle(
                          color: Color(0xFF000000).withOpacity(0.70),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (students.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Nenhum aluno encontrado.',
                        style: TextStyle(
                          color: Color(0xFF000000).withOpacity(0.70),
                          fontSize: 16,
                        ),
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
    if (stop['name'] == null || stop['status'] == null) continue;

    sections.add(Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
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
              if (student['name'] == null || student['status'] == null) return SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: StudentStatus(
                  studentName: student['name'] ?? 'N/A',
                  studentStatus: student['status'] ?? 'N/A',
                  profilePictureBase64: student['profilePictureBase64'] ?? '', // Corrigido
                  busStopName: stop['name']!,
                ),
              );
            })
            .toList(),
      ],
    ));
  }
  return sections;
}

  // Mapeamento das labels para os valores numéricos usados na ordenação
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
  };

  // Função de comparação para ordenar os pontos de ônibus
  int _compareBusStopStatus(String statusA, String statusB) {
    return (busStopStatusOrder[statusA] ?? 0).compareTo(busStopStatusOrder[statusB] ?? 0);
  }

  // Função de comparação para ordenar os alunos
  int _compareStudentStatus(String statusA, String statusB) {
    return (studentStatusOrder[statusA] ?? 0).compareTo(studentStatusOrder[statusB] ?? 0);
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
    List<dynamic> data = decodeJsonResponse(response);

    // Printando os dados recebidos
    print("Dados recebidos: $data");

    return data.map((item) => Map<String, String>.from({
      'name': item['student_name'] as String? ?? '',
      'status': item['student_status'] as String? ?? '',
      'profilePictureBase64': item['profile_picture'] as String? ?? '', // Use a imagem em base64
      'busStop': item['bus_stop_name'] as String? ?? '',
    })).toList();
  } else if (response.statusCode == 404) {
    print("Nenhum dado encontrado para o tripId: $tripId");
    return [];
  } else {
    print("Erro ao carregar os detalhes da viagem dos estudantes, status code: ${response.statusCode}");
    throw Exception('Failed to load student trip details');
  }
}

Future<List<Map<String, String>>> fetchBusStops(int tripId) async {
  var url = Uri.parse('http://127.0.0.1:8000/trips/$tripId/bus_stops');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    List<dynamic> data = decodeJsonResponse(response);
    return data.map((item) => Map<String, String>.from({
      'name': item['name'] as String?,
      'status': item['status'] as String?,
    })).toList();
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception('Failed to load bus stop details');
  }
}
