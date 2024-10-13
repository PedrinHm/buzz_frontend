import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:buzz/screens/Auth/login_screen.dart';
import 'package:buzz/screens/main_screen.dart';
import 'package:buzz/controllers/trip_controller.dart';
import 'package:buzz/models/usuario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensagem recebida em segundo plano: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

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
          fontFamily: 'Inter', 
        ),
        initialRoute: '/login', 
        routes: {
          '/login': (context) => LoginScreen(), 
          '/main': (context) => MainScreen(
                usuario: Usuario(tipoUsuario: 'student', id: 1),
              ),
        },
        onGenerateRoute: (settings) {
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
          return null; 
        },
      ),
    );
  }
}
