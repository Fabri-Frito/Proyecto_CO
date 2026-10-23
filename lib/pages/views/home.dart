import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_co/pages/views/dispositivos.dart';

/*  
  Esta clase representa la vista principal de la aplicación, que contiene una barra de navegación con 
  pestañas para mostrar los dispositivos (sensores y válvulas) y un botón para cerrar sesión.
  Muestra el nombre del usuario autenticado en la esquina superior derecha.
*/
class Homeview extends StatelessWidget {
  const Homeview({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario actual de Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    // Prioriza el nombre de registro, sino el correo, sino un nombre por defecto
    final String userName = user?.displayName ?? "Usuario";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Estructura principal de la vista con barra de navegación y contenido
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFFC61A2B),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50.0)),
          ),
          title: Row(
            // Contenedor para el icono, el título y el botón de cerrar sesión
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 50,
              ),
              const SizedBox(width: 8),
              const Text(
                "Detect And Prevent",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(), // Reemplaza los paddings fijos para que se ajuste bien a cualquier pantalla
              TextButton(
                onPressed: () async {
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
          bottom: const TabBar(
            // Barra de navegación con pestañas para cambiar entre sensores y válvulas
            dividerColor: Colors.transparent,
            indicatorColor: Colors.white,
            indicatorWeight: 5,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Sensores"),
              Tab(text: "Valvulas"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            DispositivosTab(
              tipo: 'detectores',
              etiqueta: 'Detector',
              color: const Color(0xFFC61A2B),
              textoEstado: (data) =>
                  (data['estado'] ?? 'Desconocido').toString(),
              detalle: (id, nombre) => DetalleDetector(id: id, nombre: nombre),
            ),
            DispositivosTab(
              tipo: 'valvulas',
              etiqueta: 'Válvula',
              color: const Color(0xFF1A1A1A),
              textoEstado: (data) =>
                  data['abierta'] == true ? 'Abierta' : 'Cerrada',
              detalle: (id, nombre) => DetalleValvula(id: id, nombre: nombre),
            ),
          ],
        ),
      ),
    );
  }
}
