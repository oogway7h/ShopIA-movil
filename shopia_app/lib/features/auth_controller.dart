import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/apiService.dart';
import '../services/firebase_messaging_service.dart';
import 'dart:convert';

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

      ApiService.token = _token;

      await _saveToStorage();

      // 🆕 Enviar token FCM después del login exitoso
      await FirebaseMessagingService.enviarTokenAlBackend();

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
    ApiService.token = null;
    _error = null;
    await _clearStorage();
    notifyListeners();
  }

  // Cuando cargas usuario guardado:
  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedUserJson = prefs.getString('user');

    if (savedToken != null && savedUserJson != null) {
      try {
        _token = savedToken;
        ApiService.token = _token;
        _user = User.fromJson(json.decode(savedUserJson));

        // 🆕 Enviar token FCM si el usuario ya estaba logueado
        await FirebaseMessagingService.enviarTokenAlBackend();

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
    await prefs.setString(
      'user',
      json.encode({
        'id': _user!.id,
        'correo': _user!.correo,
        'nombre': _user!.nombre,
        'apellido': _user!.apellido,
        'roles': _user!.roles.map((r) => {'nombre': r}).toList(),
        'telefono': _user!.telefono,
        'sexo': _user!.sexo,
        'estado': _user!.estado,
      }),
    );
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
