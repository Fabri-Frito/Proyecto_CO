import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*  
  Esta clase es un controlador de configuración que maneja las preferencias del usuario, como notificaciones, modo oscuro y idioma.
  Utiliza SharedPreferences para almacenar y recuperar estas configuraciones de manera persistente.
  Implementa el patrón Singleton para asegurar que solo haya una instancia de este controlador en toda la aplicación.
*/
class SettingsController extends ChangeNotifier {
  SettingsController._();
  static final SettingsController instance = SettingsController._();

  late SharedPreferences _prefs;

  bool notificationsEnabled = true;
  bool darkMode = false;
  Locale locale = const Locale('es');

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    notificationsEnabled = _prefs.getBool('notifications') ?? true;
    darkMode = _prefs.getBool('darkMode') ?? false;
    locale = Locale(_prefs.getString('language') ?? 'es');
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled = value;
    await _prefs.setBool('notifications', value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await _prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    locale = Locale(code);
    await _prefs.setString('language', code);
    notifyListeners();
  }
}
