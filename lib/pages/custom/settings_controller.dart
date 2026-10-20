import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
