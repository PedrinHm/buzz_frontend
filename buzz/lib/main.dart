import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:buzz/screens/Auth/login_screen.dart';
import 'package:buzz/screens/main_screen.dart';
import 'package:buzz/controllers/trip_controller.dart';
import 'package:buzz/models/usuario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Função para lidar com notificações em segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicialize o Firebase para garantir que esteja pronto para processar as mensagens
  await Firebase.initializeApp();
  print('Mensagem recebida em segundo plano: ${message.messageId}');
}

void main() async {
  // Garantir que a inicialização dos widgets Flutter e do Firebase seja feita corretamente
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialize o Firebase antes de qualquer outra operação que dependa dele
  await Firebase.initializeApp();

  // Configurar o Firebase Messaging para lidar com mensagens em segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripController(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter', // Defina a família de fontes padrão como Inter
        ),
        initialRoute: '/login', // Define a rota inicial como login
        routes: {
          '/login': (context) => LoginScreen(), // Rota da tela de login
          '/main': (context) => MainScreen(
                usuario: Usuario(tipoUsuario: 'student', id: 1),
              ), // Exemplo de rota para a tela principal
          // Adicione outras rotas conforme necessário
        },
        onGenerateRoute: (settings) {
          // Se a rota não estiver registrada, navegue para uma tela de erro ou a tela de login
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => LoginScreen(),
            );
          } else if (settings.name == '/main') {
            return MaterialPageRoute(
              builder: (context) => MainScreen(
                usuario: Usuario(tipoUsuario: 'student', id: 1),
              ),
            );
          }
          return null; // Retorna nulo se a rota não for encontrada
        },
      ),
    );
  }
}
