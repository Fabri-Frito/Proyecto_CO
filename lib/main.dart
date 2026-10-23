import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_co/firebase_options.dart';
import 'pages/auth_screen.dart';
import 'pages/home_screen.dart';
import 'pages/custom/settings_controller.dart';

/*
  Este es el punto de entrada principal de la aplicación.
  Inicializa Firebase y configura la aplicación para que use el tema y la configuración del usuario.
  Dependiendo del estado de autenticación del usuario, muestra la pantalla de inicio o la pantalla de autenticación.
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SettingsController.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Construye la aplicación principal y escucha los cambios en la configuración del usuario
    return ListenableBuilder(
      listenable: SettingsController.instance,
      builder: (context, _) {
        final s = SettingsController.instance;
        return MaterialApp(
          debugShowCheckedModeBanner:
              false, // Desactiva la bandera de depuración en la esquina superior derecha
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: s.darkMode
              ? ThemeMode.dark
              : ThemeMode
                    .light, // Cambia el tema según la configuración del usuario
          locale: s.locale,
          home: StreamBuilder<User?>(
            // Escucha los cambios en el estado de autenticación del usuario
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                // Si el usuario está autenticado, muestra la pantalla de inicio
                return const Home();
              }
              return const AuthScreen(); // Si el usuario no está autenticado, muestra la pantalla de autenticación
            },
          ),
        );
      },
    );
  }
}
