import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/apiService.dart';

class AuthController extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _token != null;

  // Login
  Future<bool> login(String correo, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _api.post('cuenta/token/', {
        'correo': correo,
        'password': password,
      });

      _token = response['access'];
      _user = User.fromJson(response['usuario']);

      // Guardar en almacenamiento local
      await _saveToStorage();

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;
    await _clearStorage();
    notifyListeners();
  }

  // Cargar datos guardados al iniciar app
  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedUserJson = prefs.getString('user');

    if (savedToken != null && savedUserJson != null) {
      try {
        _token = savedToken;
        _user = User.fromJson(
          Map<String, dynamic>.from(
            // Simple parsing, en producción usa json.decode
            {},
          ),
        );
        notifyListeners();
      } catch (e) {
        await _clearStorage();
      }
    }
  }

  // Helpers privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    // En producción, serializa el user completo
    await prefs.setString('user', _user!.correo);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
