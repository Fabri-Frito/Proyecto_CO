import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controladores específicos para el REGISTRO (Sign Up)
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();

  // Controladores específicos para el INICIO DE SESIÓN (Sign In)
  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para registrar usuario (Sign Up)
  Future<void> _signUp() async {
    // Validación local rápida antes de ir a Firebase
    if (_signUpEmailController.text.trim().isEmpty ||
        _signUpPasswordController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, completa todos los campos.');
      return;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _signUpEmailController.text.trim(),
            password: _signUpPasswordController.text.trim(),
          );

      await userCredential.user?.updateDisplayName(
        _signUpNameController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // Captura los errores específicos de Firebase para el Registro
      String mensajeAmigable =
          'Ocurrió un error inesperado. Inténtalo de nuevo.';

      switch (e.code) {
        case 'email-already-in-use':
          mensajeAmigable =
              'Este correo electrónico ya está registrado con otra cuenta.';
          break;
        case 'invalid-email':
          mensajeAmigable = 'El formato del correo electrónico no es válido.';
          break;
        case 'weak-password':
          mensajeAmigable =
              'La contraseña es muy débil. Intenta con al menos 6 caracteres.';
          break;
        case 'network-request-failed':
          mensajeAmigable = 'No hay conexión a internet. Verifica tu red.';
          break;
      }

      _showErrorDialog(mensajeAmigable);
    } catch (e) {
      _showErrorDialog('Error general: ${e.toString()}');
    }
  }

  // Función para iniciar sesión (Sign In / Login)
  Future<void> _signIn() async {
    if (_signInEmailController.text.trim().isEmpty ||
        _signInPasswordController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, ingresa tu correo y contraseña.');
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // Captura los errores específicos de Firebase para el Login
      String mensajeAmigable = 'Ocurrió un error al iniciar sesión.';

      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          mensajeAmigable =
              'El correo electrónico o la contraseña son incorrectos.';
          break;
        case 'invalid-email':
          mensajeAmigable = 'El formato del correo electrónico no es válido.';
          break;
        case 'user-disabled':
          mensajeAmigable = 'Esta cuenta de usuario ha sido deshabilitada.';
          break;
        case 'too-many-requests':
          mensajeAmigable =
              'Demasiados intentos fallidos. Cuenta bloqueada temporalmente.';
          break;
        case 'network-request-failed':
          mensajeAmigable = 'No hay conexión a internet. Verifica tu red.';
          break;
      }

      _showErrorDialog(mensajeAmigable);
    } catch (e) {
      _showErrorDialog('Error general: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();

    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    super.dispose();
  }

  bool pasvisible = true;

  @override
  void initState() {
    super.initState();
    pasvisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0, // Inicia en la pestaña de Sign Up
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 140,
          backgroundColor: const Color(0xFFC61A2B),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.0)),
          ),
          title: Row(
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
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Crear"),
              Tab(text: "Iniciar"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildSignUpForm(), _buildSignInForm()]),
        bottomNavigationBar: Container(
          height: 60,
          decoration: const BoxDecoration(color: Color(0xFFC61A2B)),
        ),
      ),
    );
  }

  // Formulario Registro
  Widget _buildSignUpForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Crea una Cuenta',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            hintText: 'Nombre',
            controller: _signUpNameController,
            maxlengt: 20,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Correo Electronico',
            controller: _signUpEmailController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Contraseña',
            controller: _signUpPasswordController,
            obscureText: !pasvisible,
            helperText: "Caracteres en minuscula y numericos",
          ),
          const SizedBox(height: 35),
          _buildActionButton(text: 'Crear', onPressed: _signUp),
        ],
      ),
    );
  }

  // Formulario Login
  Widget _buildSignInForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Bienvenido!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            hintText: 'Correo Electronico',
            controller: _signInEmailController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            hintText: 'Contraseña',
            controller: _signInPasswordController,
            obscureText: !pasvisible,
          ),
          const SizedBox(height: 35),
          _buildActionButton(text: 'Iniciar', onPressed: _signIn),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    int? maxlengt,
    String? helperText,
  }) {
    return TextField(
      maxLength: maxlengt,
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.red,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        // Borde cuando estás escribiendo en el campo
        focusedBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 3),
        ),
        hintText: hintText,
        helperText: helperText,
        helperStyle: const TextStyle(color: Colors.red),
        counterStyle: const TextStyle(color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: hintText == "Contraseña"
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    pasvisible = !pasvisible;
                  });
                },
              )
            : null,
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
