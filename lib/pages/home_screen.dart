import 'package:flutter/material.dart';
import 'package:proyecto_co/pages/views/home.dart';
import 'package:proyecto_co/pages/views/setting.dart';
import 'package:proyecto_co/pages/views/contact.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Homeview(),
      const Settingview(),
      const Contactview(),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: IndexedStack(index: selectedIndex, children: screens),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (newIndex) {
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
              icon: const Icon(Icons.home),
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: "Configuracion",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.help_outline),
              label: "Contacto y ayuda",
            ),
          ],
        ),
      ),
    );
  }
}
