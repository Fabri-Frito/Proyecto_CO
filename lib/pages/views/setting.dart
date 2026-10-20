import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_co/pages/custom/settings_controller.dart';

class Settingview extends StatelessWidget {
  const Settingview({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario actual de Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    // Prioriza el nombre de registro, sino el correo, sino un nombre por defecto
    final String userName = user?.displayName ?? "Usuario";

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFC61A2B),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(50.0)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, color: Colors.white, size: 50),
            const SizedBox(width: 8),
            const Text(
              "Configuracion",
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
      body: _settings(context),
    );
  }

  Widget _settings(BuildContext context) {
    final s = SettingsController.instance;

    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Apariencia',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
            ),
          ),
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: s.darkMode,
            onChanged: s.setDarkMode,
          ),
          SwitchListTile(
            title: const Text('Notificaciones'),
            value: s.notificationsEnabled,
            onChanged: s.setNotifications,
          ),
          ListTile(
            title: const Text('Idioma'),
            trailing: DropdownButton<String>(
              value: s.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (code) {
                if (code != null) s.setLanguage(code);
              },
            ),
          ),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              return ListTile(
                title: const Text('Nombre de usuario'),
                subtitle: Text(snapshot.data?.displayName ?? 'Usuario'),
                trailing: const Icon(Icons.edit),
                onTap: () => _changeName(context),
              );
            },
          ),
          ListTile(
            title: const Text('Cambiar contraseña'),
            trailing: const Icon(Icons.lock_outline),
            onTap: () => _changePassword(context),
          ),
        ],
      ),
    );
  }

  Future<void> _changeName(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final controller = TextEditingController(text: user?.displayName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar nombre'),
        content: TextField(controller: controller, maxLength: 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await user?.updateDisplayName(newName);
      await user?.reload();
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;
    bool loading = false;

    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                ),
              ),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  errorText: errorText,
                  errorMaxLines: 3,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: loading
                  ? null
                  : () async {
                      final current = currentController.text.trim();
                      final nueva = newController.text.trim();
                      final confirmar = confirmController.text.trim();

                      if (current.isEmpty ||
                          nueva.isEmpty ||
                          confirmar.isEmpty) {
                        setDialogState(
                          () => errorText = 'Completa todos los campos.',
                        );
                        return;
                      }
                      if (nueva != confirmar) {
                        setDialogState(
                          () => errorText =
                              'Las contraseñas nuevas no coinciden.',
                        );
                        return;
                      }
                      if (nueva.length < 6) {
                        setDialogState(
                          () => errorText = 'Debe tener al menos 6 caracteres.',
                        );
                        return;
                      }

                      setDialogState(() {
                        loading = true;
                        errorText = null;
                      });

                      try {
                        final user = FirebaseAuth.instance.currentUser!;
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: current,
                        );
                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(nueva);
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } on FirebaseAuthException catch (e) {
                        String msg = 'Ocurrió un error. Inténtalo de nuevo.';
                        switch (e.code) {
                          case 'wrong-password':
                          case 'invalid-credential':
                            msg = 'La contraseña actual es incorrecta.';
                            break;
                          case 'weak-password':
                            msg = 'La nueva contraseña es muy débil.';
                            break;
                          case 'too-many-requests':
                            msg = 'Demasiados intentos. Prueba más tarde.';
                            break;
                          case 'network-request-failed':
                            msg = 'No hay conexión a internet.';
                            break;
                        }
                        setDialogState(() {
                          loading = false;
                          errorText = msg;
                        });
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (success == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente.')),
      );
    }
  }
}
