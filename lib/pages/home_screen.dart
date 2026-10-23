import 'package:flutter/material.dart';
import 'package:proyecto_co/pages/views/home.dart';
import 'package:proyecto_co/pages/views/setting.dart';
import 'package:proyecto_co/pages/views/contact.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

/*  
  Esta clase representa la pantalla principal de la aplicación, que contiene una barra de navegación inferior 
  con pestañas para mostrar la vista de inicio, configuración y contacto.
  Utiliza un IndexedStack para mantener el estado de cada vista mientras se navega entre ellas.
*/
class _HomeState extends State<Home> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Definimos las pantallas que se mostrarán en el IndexedStack
    final screens = [
      const Homeview(),
      const Settingview(),
      const Contactview(),
    ];

    return DefaultTabController(
      // Controlador de pestañas para manejar la navegación entre las vistas
      length: 2,
      child: Scaffold(
        body: IndexedStack(index: selectedIndex, children: screens),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              selectedIndex, // Mantiene la pestaña seleccionada en la barra de navegación
          onTap: (newIndex) {
            // Actualiza el índice seleccionado y reconstruye la interfaz
            setState(() {
              selectedIndex = newIndex;
            });
          },
          elevation: 0,
          backgroundColor: const Color(0xFFC61A2B),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              // inicio
              icon: const Icon(Icons.home),
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              // configuracion
              icon: const Icon(Icons.settings),
              label: "Configuracion",
            ),
            BottomNavigationBarItem(
              // ayuda
              icon: const Icon(Icons.help_outline),
              label: "Contacto y ayuda",
            ),
          ],
        ),
      ),
    );
  }
}
