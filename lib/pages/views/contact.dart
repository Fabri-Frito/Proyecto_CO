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
        body: const TabBarView(children: [Center(child: Text("Contact"))]),
      ),
    );
  }
}
