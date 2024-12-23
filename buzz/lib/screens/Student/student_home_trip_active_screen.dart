import 'package:buzz/screens/Admin/form_screen.dart';
import 'package:buzz/utils/size_config.dart';
import 'package:buzz/widgets/Geral/Custom_pop_up.dart';
import 'package:buzz/widgets/Geral/buildOverlay.dart';
import 'package:provider/provider.dart';
import 'package:buzz/widgets/Student/Bus_Button_Home.dart';
import 'package:buzz/widgets/Student/Bus_Stop_Button_Home.dart';
import 'package:buzz/widgets/Student/Message_Home.dart';
import 'package:buzz/widgets/Student/Status_Button_Home.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:buzz/widgets/Geral/Button_Three.dart';
import 'package:buzz/widgets/Student/bus_details_button.dart';
import 'package:buzz/widgets/Geral/Bus_Stop_Trip.dart';
import 'package:buzz/widgets/Student/status_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:buzz/config/config.dart';

class StudentHomeTripActiveScreen extends StatefulWidget {
  final int studentId;
  final int tripId;
  final int studentTripId;

  StudentHomeTripActiveScreen({
    required this.studentId,
    required this.tripId,
    required this.studentTripId,
  });

  @override
  _StudentHomeTripActiveScreenState createState() =>
      _StudentHomeTripActiveScreenState();
}

class _StudentHomeTripActiveScreenState
    extends State<StudentHomeTripActiveScreen> {
  bool _showBusOverlay = false;
  bool _showBusStopOverlay = false;
  bool _showStatusOverlay = false;
  bool isLoadingBusStop = true;
  List<Map<String, dynamic>> _busList = [];
  List<Map<String, String>> busStopList = [];
  List<Map<String, dynamic>> _statusList = []; // Lista de status disponíveis
  bool isLoading = false;
  bool isUpdatingStatus = false;
  late int _studentTripId;
  int? _currentStatus; // Status atual do aluno como int
  String? _busStopName;
  bool isLoadingBus = true;
  String? _busNumber;
  String? _driverName;
  late int _currentTripId;

  // Mapeamento de status numérico para rótulos e cores
  final Map<int, Map<String, dynamic>> statusDetails = {
    1: {
      'statusText': 'Presente',
      'color': Color(0xFF3E9B4F),
      'icon': PhosphorIcons.check
    },
    2: {
      'statusText': 'Em aula',
      'color': Color(0xFF395BC7),
      'icon': PhosphorIcons.chalkboardTeacher
    },
    3: {
      'statusText': 'Aguardando ônibus',
      'color': Color(0xFFB0E64C),
      'icon': PhosphorIcons.bus
    },
    4: {
      'statusText': 'Não voltará',
      'color': Color(0xFFFFBA18),
      'icon': PhosphorIcons.x
    },
    5: {
      'statusText': 'Fila de espera',
      'color': Color(0xFFFFBA18),
      'icon': PhosphorIcons.x
    },
  };

  @override
  void initState() {
    super.initState();
    _studentTripId = widget.studentTripId;
    _currentTripId = widget.tripId;
    _fetchCurrentStatus();
    _fetchBusStopName();
    _fetchBusAndDriver();
  }

  void _toggleBusOverlay() async {
    try {
      final tripResponse = await http
          .get(Uri.parse('${Config.backendUrl}/trips/${widget.tripId}'));

      if (tripResponse.statusCode == 200) {
        final tripData = json.decode(tripResponse.body);

        // Se for viagem de volta (trip_type = 2), aplica as restrições de status
        if (tripData['trip_type'] == 2) {
          if (_currentStatus == 2 || _currentStatus == 5) {
            // 2 = "Em aula", 5 = "Fila de espera"
            setState(() {
              _showBusOverlay = !_showBusOverlay;
              if (_showBusOverlay) {
                _fetchActiveBuses();
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Você só pode alterar o ônibus quando estiver com o status "Em aula" ou "Fila de espera".'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Se for viagem de ida, permite alteração sem restrições
          setState(() {
            _showBusOverlay = !_showBusOverlay;
            if (_showBusOverlay) {
              _fetchActiveBuses();
            }
          });
        }
      } else {
        throw Exception('Failed to fetch trip type');
      }
    } catch (e) {
      print('Error checking trip type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao verificar tipo de viagem'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleBusStopOverlay() async {
    try {
      final tripResponse = await http
          .get(Uri.parse('${Config.backendUrl}/trips/${widget.tripId}'));

      if (tripResponse.statusCode == 200) {
        final tripData = json.decode(tripResponse.body);

        // Se for viagem de volta (trip_type = 2), aplica as restrições de status
        if (tripData['trip_type'] == 2) {
          if (_currentStatus == 2 || _currentStatus == 5) {
            // 2 = "Em aula", 5 = "Fila de espera"
            setState(() {
              _showBusStopOverlay = !_showBusStopOverlay;
              if (_showBusStopOverlay) {
                _fetchBusStops();
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Você só pode alterar o ponto de ônibus quando estiver com o status "Em aula" ou "Fila de espera".'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Se for viagem de ida, permite alteração sem restrições
          setState(() {
            _showBusStopOverlay = !_showBusStopOverlay;
            if (_showBusStopOverlay) {
              _fetchBusStops();
            }
          });
        }
      } else {
        throw Exception('Failed to fetch trip type');
      }
    } catch (e) {
      print('Error checking trip type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao verificar tipo de viagem'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleStatusOverlay() async {
    try {
      // Verifica o tipo de viagem antes de permitir alteração de status
      final tripResponse = await http
          .get(Uri.parse('${Config.backendUrl}/trips/${widget.tripId}'));

      if (tripResponse.statusCode == 200) {
        final tripData = json.decode(tripResponse.body);

        // Se for viagem de ida (trip_type = 1), não permite alteração
        if (tripData['trip_type'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Não é possível alterar o status durante uma viagem de ida.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Se não for viagem de ida, continua normalmente
        setState(() {
          _showStatusOverlay = !_showStatusOverlay;
          if (_showStatusOverlay) {
            _fetchAvailableStatus();
          }
        });
      } else {
        throw Exception('Failed to fetch trip type');
      }
    } catch (e) {
      print('Error checking trip type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao verificar tipo de viagem'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchBusAndDriver() async {
    try {
      setState(() {
        isLoadingBus = true;
      });

      print('Buscando dados do ônibus e motorista...');
      print('Trip ID atual: $_currentTripId');

      final tripResponse = await http
          .get(Uri.parse('${Config.backendUrl}/trips/$_currentTripId'));

      if (tripResponse.statusCode == 200) {
        final tripData = decodeJsonResponse(tripResponse);
        final busId = tripData['bus_id'];
        final driverId = tripData['driver_id'];

        print('Dados da viagem:');
        print('Bus ID: $busId');
        print('Driver ID: $driverId');

        final busResponse =
            await http.get(Uri.parse('${Config.backendUrl}/buses/$busId'));
        if (busResponse.statusCode == 200) {
          final busData = decodeJsonResponse(busResponse);
          print('Dados do ônibus antes da atualização:');
          print('Número atual: $_busNumber');
          print('Novo número: ${busData['registration_number']}');
          
          setState(() {
            _busNumber = busData['registration_number'];
          });
        }

        final driverResponse =
            await http.get(Uri.parse('${Config.backendUrl}/users/$driverId'));
        if (driverResponse.statusCode == 200) {
          final driverData = decodeJsonResponse(driverResponse);
          print('Dados do motorista antes da atualização:');
          print('Nome atual: $_driverName');
          print('Novo nome: ${driverData['name']}');
          
          setState(() {
            _driverName = driverData['name'];
          });
        }
      }
    } catch (e) {
      print('Erro ao buscar dados do ônibus e motorista: $e');
    } finally {
      setState(() {
        isLoadingBus = false;
      });
    }
  }

  Future<void> _fetchBusStopName() async {
    try {
      setState(() {
        isLoadingBusStop = true;
      });

      final response = await http.get(Uri.parse(
          '${Config.backendUrl}/student_trips/${widget.studentTripId}'));

      if (response.statusCode == 200) {
        final data = decodeJsonResponse(response); // Decodificação com utf8
        final pointId = data['point_id'];

        final busStopResponse = await http
            .get(Uri.parse('${Config.backendUrl}/bus_stops/$pointId'));

        if (busStopResponse.statusCode == 200) {
          final busStopData =
              decodeJsonResponse(busStopResponse); // Decodificação com utf8
          setState(() {
            _busStopName =
                busStopData['name']; // Dados decodificados corretamente
          });
        } else {
          throw Exception('Failed to fetch bus stop name');
        }
      } else {
        throw Exception('Failed to fetch student trip');
      }
    } catch (e) {
      print('Error fetching bus stop name: $e');
    } finally {
      setState(() {
        isLoadingBusStop = false;
      });
    }
  }

  Future<void> _fetchCurrentStatus() async {
    try {
      // Faz uma chamada HTTP para buscar o status atual do aluno
      final response = await http.get(Uri.parse(
          '${Config.backendUrl}/student_trips/${widget.studentTripId}'));

      if (response.statusCode == 200) {
        final data = decodeJsonResponse(response);
        setState(() {
          _currentStatus = data['status']; // status numérico recebido da API
        });
      } else {
        throw Exception('Failed to fetch current status');
      }
    } catch (e) {
      print('Error fetching current status: $e');
    }
  }

  Future<void> _fetchAvailableStatus() async {
    if (_currentStatus == null) {
      print('Current status is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: Status atual não está definido!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Definindo os status permitidos para cada status atual
    final Map<int, List<int>> allowedTransitions = {
      2: [3, 4, 1], // Em aula para Aguardando no ponto, Não voltará, Presente
      3: [1, 2, 4], // Aguardando no ponto para Presente, Em aula, Não voltará
      4: [1, 2, 3], // Não voltará para Presente, Em aula, Aguardando no ponto
      5: [
        1,
        2,
        3,
        4
      ], // Fila de espera para Presente, Em aula, Aguardando no ponto, Não voltará
      1: [4] // Presente para Não voltará
    };

    final List<int>? possibleStatuses = allowedTransitions[_currentStatus];

    if (possibleStatuses == null) {
      print('Erro: Transições permitidas não encontradas para o status atual!');
      return;
    }

    setState(() {
      // Cria uma lista de opções de status permitidos com base no status atual
      _statusList = possibleStatuses
          .map((status) => {
                'status': status,
                ...statusDetails[status]!,
              })
          .toList();
    });
  }

  Future<void> _updateStudentTripStatus(int newStatus) async {
    if (_studentTripId == null) {
      print('Student trip ID is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: Student trip ID não está definido!'),
          backgroundColor: Colors.red, // Cor vermelha para erros
        ),
      );
      return;
    }

    try {
      // Primeiro, verifique o tipo de viagem
      final tripResponse = await http
          .get(Uri.parse('${Config.backendUrl}/trips/${widget.tripId}'));

      if (tripResponse.statusCode == 200) {
        final tripData = json.decode(tripResponse.body);

        // Se for uma viagem de ida, exiba um erro e não prossiga
        if (tripData['trip_type'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro: Não é possível alterar o status durante uma viagem de ida.'),
              backgroundColor: Colors.red, // Cor vermelha para erros
            ),
          );
          return; // Interrompe a execução aqui se for viagem de ida
        }
      } else {
        throw Exception('Failed to fetch trip type');
      }

      // Atualiza o status do aluno
      final url = Uri.parse(
          '${Config.backendUrl}/student_trips/$_studentTripId/update_status?new_status=$newStatus');
      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('Status do aluno atualizado com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status do aluno atualizado com sucesso!'),
            backgroundColor: Colors.green, // Cor verde para sucesso
          ),
        );
        await _fetchCurrentStatus();
      } else {
        // Decodifica a resposta de erro e exibe o detalhe
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail =
            errorData['detail'] ?? 'Erro ao atualizar o status do aluno';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao atualizar o status do aluno: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar o status do aluno'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUpdatingStatus = false;
      });
    }
  }

  Future<void> _fetchActiveBuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          '${Config.backendUrl}/buses/available_for_student?student_id=${widget.studentId}'));

      if (response.statusCode == 200) {
        List<dynamic> data = decodeJsonResponse(response);

        setState(() {
          _busList = data
              .map((item) => {
                    'busId': item['bus_id'],
                    'tripId': item['trip_id'],
                    'registrationNumber': item['registration_number'],
                    'name': item['name'],
                    'capacity': item['capacity'],
                    'tripType': item['trip_type'],
                    'availableSeats': item['available_seats'] ?? 0,
                  })
              .toList();
        });

        // Adiciona verificação para lista vazia
        if (_busList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Não há viagens em andamento no momento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Failed to load available buses for student');
      }
    } catch (e) {
      print('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não há viagens em andamento no momento'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBusStops() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          '${Config.backendUrl}/bus_stops/action/trip?student_id=${widget.studentId}&trip_id=${widget.tripId}'));

      if (response.statusCode == 200) {
        List<dynamic> data = decodeJsonResponse(response);

        setState(() {
          busStopList = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'name': item['name'] as String,
                    'status': item['status'] as String,
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateStudentTrip(int newTripId) async {
    if (_studentTripId == null) {
      print('Student trip ID is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: Student trip ID não está definido!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Iniciando atualização da viagem...');
    print('Trip ID atual: $_currentTripId');
    print('Novo Trip ID: $newTripId');

    setState(() {
      isLoadingBus = true;
    });

    try {
      final response = await http.put(Uri.parse(
          '${Config.backendUrl}/student_trips/$_studentTripId/update_trip?new_trip_id=$newTripId'));

      if (response.statusCode == 200) {
        setState(() {
          _currentTripId = newTripId; // Atualiza o ID da viagem atual
        });
        
        print('Viagem do aluno atualizada com sucesso!');
        print('Atualizando Trip ID de ${_currentTripId} para $newTripId');
        
        // Atualiza os dados do ônibus e motorista
        print('Buscando novos dados do ônibus e motorista...');
        await _fetchBusAndDriver();
        
        print('Dados após atualização:');
        print('Número do ônibus: $_busNumber');
        print('Nome do motorista: $_driverName');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viagem do aluno atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _showBusOverlay = false;
        });
        
      } else if (response.statusCode == 400) {
        final decodedBody = utf8.decode(response.bodyBytes);
        print('Decoded Response Body: $decodedBody');

        if (response.body.contains("Nova viagem estÃ¡ cheia")) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomPopup(
                message: 'A viagem está cheia. Deseja entrar na fila de espera?',
                confirmText: 'Sim',
                cancelText: 'Não',
                onConfirm: () {
                  Navigator.of(context).pop();
                  _enterWaitlist(newTripId);
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
        }
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail = errorData['detail'] ?? 'Erro ao atualizar a viagem do aluno';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao atualizar a viagem do aluno: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar a viagem do aluno'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingBus = false;
      });
    }
  }

  Future<void> _enterWaitlist(int newTripId) async {
    try {
      final response = await http.put(Uri.parse(
          '${Config.backendUrl}/student_trips/$_studentTripId/update_trip?new_trip_id=$newTripId&waitlist=true'));

      if (response.statusCode == 200) {
        setState(() {
          _currentTripId = newTripId; // Atualiza o ID da viagem atual
        });
        
        print('Aluno entrou na fila de espera com sucesso!');
        print('Atualizando Trip ID de $_currentTripId para $newTripId');
        
        // Atualiza os dados do ônibus e motorista
        print('Buscando novos dados do ônibus e motorista...');
        await _fetchBusAndDriver();
        
        print('Dados após atualização:');
        print('Número do ônibus: $_busNumber');
        print('Nome do motorista: $_driverName');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Você entrou na fila de espera com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _showBusOverlay = false;
        });
      } else {
        // Decodifica a resposta de erro e exibe o detalhe
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail =
            errorData['detail'] ?? 'Erro ao entrar na fila de espera';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao entrar na fila de espera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao entrar na fila de espera'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStudentTripPoint(int pointId) async {
    if (_studentTripId == null) {
      print('Student trip ID is not set');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: Student trip ID não está definido!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final url = Uri.parse(
          '${Config.backendUrl}/student_trips/$_studentTripId/update_point?point_id=$pointId');

      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('Ponto de ônibus atualizado com sucesso!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ponto de ônibus atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Após atualizar o ponto, recarregue o nome do ponto de ônibus
        await _fetchBusStopName();

        // Atualizar a interface após a alteração
        setState(() {
          _showBusStopOverlay = false; // Fechar o overlay de pontos de ônibus
        });
      } else {
        // Decodifica a resposta de erro e exibe o detalhe
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorDetail =
            errorData['detail'] ?? 'Erro ao atualizar o ponto de ônibus';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorDetail),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao atualizar o ponto de ônibus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar o ponto de ônibus'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                    height: getHeightProportion(
                        context, 40)), // Proporção para altura
                FullScreenMessage(
                  message: 'Seja bem vindo ao Buzz!',
                ),
                SizedBox(height: getHeightProportion(context, 10)),
                SizedBox(height: getHeightProportion(context, 10)),
                CustomStatus(
                  onPressed: _toggleStatusOverlay,
                  StatusName: isUpdatingStatus
                      ? 'Carregando...'
                      : statusDetails[_currentStatus]?['statusText'] ??
                          'Definir status',
                  iconData: statusDetails[_currentStatus]?['icon'] ??
                      PhosphorIcons.chalkboardTeacher,
                ),
                SizedBox(height: getHeightProportion(context, 10)),
                CustomBusStopButton(
                  onPressed: _toggleBusStopOverlay,
                  busStopName: isLoadingBusStop
                      ? 'Carregando...'
                      : _busStopName ?? 'Definir ponto de ônibus',
                ),

                SizedBox(height: getHeightProportion(context, 10)),
                CustomBusButton(
                  onPressed: _toggleBusOverlay,
                  busNumber: isLoadingBus
                      ? 'Carregando...'
                      : _busNumber ?? "Placa não definida",
                  driverName: isLoadingBus
                      ? 'Carregando...'
                      : _driverName ?? "Motorista não definido",
                ),
                SizedBox(height: getHeightProportion(context, 10)),
              ],
            ),
          ),
          if (_showBusOverlay)
            BuildOverlay(
              title: 'Defina seu ônibus atual',
              content: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildBusList(),
              onCancel: _toggleBusOverlay,
            ),
          if (_showBusStopOverlay)
            BuildOverlay(
              title: 'Defina seu ponto de ônibus atual',
              content: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildBusStopList(),
              onCancel: _toggleBusStopOverlay,
            ),
          if (_showStatusOverlay)
            BuildOverlay(
              title: 'Defina seu status atual',
              content: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildStatusList(),
              onCancel: _toggleStatusOverlay,
            ),
        ],
      ),
    );
  }

  Widget _buildBusList() {
    return ListView.builder(
      itemCount: _busList.length,
      itemBuilder: (context, index) {
        final bus = _busList[index];
        final int availableSeats = bus['availableSeats'];

        // Definir a cor do botão com base no número de vagas disponíveis
        final Color buttonColor = availableSeats == 0
            ? Color(0xFFFFBA18) // Amarelo se não houver vagas
            : Color(0xFF395BC7); // Azul padrão se houver vagas

        return Padding(
          padding: EdgeInsets.only(
              bottom:
                  getHeightProportion(context, 20)), // Proporção para altura
          child: BusDetailsButton(
            onPressed: () {
              _updateStudentTrip(bus['tripId']);
              _toggleBusOverlay();
            },
            busNumber: bus['registrationNumber'],
            driverName: bus['name'],
            capacity: bus['capacity'],
            availableSeats:
                availableSeats, // Passando availableSeats corretamente
            color: buttonColor, // Aplicando a cor condicional
            tripType: bus['tripType'], // Passa o tipo de viagem
          ),
        );
      },
    );
  }

  Widget _buildBusStopList() {
    return ListView.builder(
      itemCount: busStopList.length,
      itemBuilder: (context, index) {
        final busStop = busStopList[index];
        final busStopId = busStop['id'];

        return Padding(
          padding: EdgeInsets.only(
              bottom:
                  getHeightProportion(context, 20)), // Proporção para altura
          child: TripBusStop(
            onPressed: () {
              if (busStopId != null) {
                print("Selecionado ponto de ônibus: ${busStop['name']}");
                _updateStudentTripPoint(int.parse(busStopId));
              } else {
                print('Erro: ID do ponto de ônibus é nulo');
              }
              _toggleBusStopOverlay();
            },
            busStopName: busStop['name']!,
            busStopStatus: busStop['status']!,
          ),
        );
      },
    );
  }

  Widget _buildStatusList() {
    return ListView.builder(
      itemCount: _statusList.length,
      itemBuilder: (context, index) {
        final status = _statusList[index];
        return Padding(
          padding: EdgeInsets.only(
              bottom:
                  getHeightProportion(context, 20)), // Proporção para altura
          child: StatusButton(
            onPressed: () {
              _updateStudentTripStatus(status['status']);
              _toggleStatusOverlay();
            },
            statusText: status['statusText'],
            color: status['color'],
            icon: status['icon'],
          ),
        );
      },
    );
  }
}
