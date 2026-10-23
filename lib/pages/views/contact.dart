import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contactview extends StatelessWidget {
  const Contactview({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario actual de Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    // Prioriza el nombre de registro, sino el correo, sino un nombre por defecto
    final String userName = user?.displayName ?? "Usuario";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFFC61A2B),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50.0)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, color: Colors.white, size: 50),
              const SizedBox(width: 8),
              const Text(
                "Contacto",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(), // Reemplaza los paddings fijos para que se ajuste bien a cualquier pantalla
              TextButton(
                onPressed: () async {
                  // Cerrar sesión en Firebase. El StreamBuilder de main.dart se encargará del resto.
                  await FirebaseAuth.instance.signOut();
                },
                style: ButtonStyle(
                  mouseCursor: WidgetStateProperty.all<MouseCursor>(
                    SystemMouseCursors.click,
                  ),
                ),
                child: Text(
                  userName, // Muestra el nombre real del usuario logueado
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Título de Información del Proyecto
            const Text(
              'Acerca de Detect and Prevent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Detalle del Proyecto (Corregido con comillas triples para permitir saltos de línea)
            const ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              subtitle: Text(
                '''Detect and Prevent es una parte de un proyecto llevado a cabo por un grupo de 7° año de la Escuela Técnica N° 2 de Munro y tiene el fin de demostrar todo lo que se aprendió a través de los años estudiando la tecnicatura de informática. La aplicación es de tipo IoT (Internet de las cosas), que tiene el objetivo de gestionar los detectores de gas y los dispositivos que irían conectados a una electroválvula.''',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),

            // Título de Soporte / Asistencia
            const Text(
              '¿Tienes dudas o necesitas asistencia? Elige una opción:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Opción: Llamar por teléfono
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('Llamar a Soporte'),
              subtitle: const Text('+1 800 123 4567'),
              onTap: () {},
            ),

            // Opción: Enviar correo electrónico
            ListTile(
              leading: const Icon(Icons.email, color: Colors.green),
              title: const Text('Enviar un correo'),
              subtitle: const Text('soporte@.com'),
              onTap: () {},
            ),

            const SizedBox(height: 30),

            // Titulo de emergencias
            const Text(
              'En caso de tener una emergencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // que hacer la tenr una emergencia
            const ListTile(
              subtitle: Text(
                '''Si es que llegas a tener una emergencia porque se detecto una fuga en tu domicilio te recomendamos lo siguiente: ''',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const ListTile( // Reglas de seguridad a seguir
              title: Text(
                '''Seguridad:''',
                style: TextStyle(fontSize: 18),
              ),
            ),

            ListTile( 
              leading: const Icon(Icons.security, color: Colors.blue),
              subtitle: const Text('''-Ventila el lugar.
-No generes chispas.
-No busques la fuga.
-Evacúa si la fuga es muy extensa.'''),
            ),

            const ListTile( // Llamadas de emergencia
              title: Text(
                '''Llamadas:''',
                style: TextStyle(fontSize: 18),
              ),
            ),

            ListTile( // Opción: Los bomberos
              leading: const Icon(Icons.local_fire_department, color: Colors.blue),
              title: const Text('Bomberos:'),
              subtitle: const Text('Marca al 100'),
            ),

            ListTile( // Opción: La defensa civil
              leading: const Icon(Icons.shield, color: Colors.blue),
              title: const Text('Defensa Civil:'),
              subtitle: const Text('Marca al 103'),
            ),

            ListTile( // Opción: MetroGAS
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('MetroGAS (CABA y gran parte del GBA Sur/Oeste)::'),
              subtitle: const Text(' 0800-999-1050'),
              onTap: () {},
            ),

            ListTile( // Opción: Naturgy BAN
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('Naturgy BAN (Zona Norte y Oeste del GBA):'),
              subtitle: const Text('0800-888-1137 o 4754-1137'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
