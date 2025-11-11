import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _defaultBaseUrl =
      'https://web-production-1a81d.up.railway.app/api';
  static String _currentBaseUrl = _defaultBaseUrl;
  static String? token;

  // Getter para obtener la URL actual
  static String get baseUrl => _currentBaseUrl;

  // 🧟 PROTOCOLO ZOMBIE: Cambiar baseUrl dinámicamente
  static Future<void> activarProtocoloZombie(String nuevaUrl) async {
    // Asegurarse de que termine con /api
    String urlLimpia = nuevaUrl.trim();
    if (urlLimpia.endsWith('/')) {
      urlLimpia = urlLimpia.substring(0, urlLimpia.length - 1);
    }
    if (!urlLimpia.endsWith('/api')) {
      urlLimpia += '/api';
    }

    _currentBaseUrl = urlLimpia;

    // Guardar en SharedPreferences para persistencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zombie_base_url', urlLimpia);
    await prefs.setBool('zombie_activated', true);
  }

  // 🧟 Restaurar URL por defecto
  static Future<void> desactivarProtocoloZombie() async {
    _currentBaseUrl = _defaultBaseUrl;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('zombie_base_url');
    await prefs.setBool('zombie_activated', false);
  }

  // 🧟 Cargar configuración guardada al iniciar
  static Future<void> cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    final zombieActivated = prefs.getBool('zombie_activated') ?? false;

    if (zombieActivated) {
      final savedUrl = prefs.getString('zombie_base_url');
      if (savedUrl != null) {
        _currentBaseUrl = savedUrl;
      }
    }
  }

  // 🧟 Verificar si está activado
  static Future<bool> esProtocoloZombieActivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('zombie_activated') ?? false;
  }

  // Genérico para GET
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final mergedHeaders = {
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    final response = await http.get(
      Uri.parse('$_currentBaseUrl/$endpoint'),
      headers: mergedHeaders,
    );
    return _handleResponse(response);
  }

  // Genérico para POST
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    final response = await http.post(
      Uri.parse('$_currentBaseUrl/$endpoint'),
      headers: mergedHeaders,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Genérico para PUT
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    final response = await http.put(
      Uri.parse('$_currentBaseUrl/$endpoint'),
      headers: mergedHeaders,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Genérico para DELETE
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    final response = await http.delete(
      Uri.parse('$_currentBaseUrl/$endpoint'),
      headers: mergedHeaders,
    );
    return _handleResponse(response);
  }

  // Manejo de respuesta
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
