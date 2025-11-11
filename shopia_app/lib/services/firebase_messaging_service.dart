import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'apiService.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Handler para notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '📩 Notificación en segundo plano: ${message.notification?.title}',
  );
}

class FirebaseMessagingService {
  static Future<void> inicializar() async {
    try {
      // 🆕 1. Solicitar permisos de NOTIFICACIONES Y ALMACENAMIENTO juntos
      final messaging = FirebaseMessaging.instance;

      // Solicitar permisos de notificaciones
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Permisos de notificaciones concedidos');
      } else {
        debugPrint('⚠️ Permisos de notificaciones denegados');
      }

      // 🆕 2. Solicitar permisos de almacenamiento inmediatamente después
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
      debugPrint('✅ Permisos de almacenamiento solicitados');

      // 3. Configurar canal de notificaciones
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'shopia_channel',
        'Notificaciones Shopia',
        description: 'Canal para notificaciones de Shopia',
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      debugPrint('✅ Canal de notificaciones creado: ${channel.id}');

      // 4. Inicializar plugin de notificaciones locales
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // 5. Escuchar notificaciones en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📩 Notificación recibida: ${message.notification?.title}');
        _mostrarNotificacionLocal(message);
      });

      // 6. Manejar clicks en notificaciones
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📱 App abierta desde notificación');
      });
    } catch (e) {
      debugPrint('❌ Error en inicialización FCM: $e');
    }
  }

  static Future<void> enviarTokenAlBackend() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint('📱 Token FCM: ${token.substring(0, 50)}...');
        await _enviarTokenAlServidor(token);
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo token: $e');
    }
  }

  static Future<void> _enviarTokenAlServidor(String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/cuenta/guardar-token-fcm/'),
            headers: {
              'Content-Type': 'application/json',
              if (ApiService.token != null)
                'Authorization': 'Bearer ${ApiService.token}',
            },
            body: jsonEncode({'fcm_token': token}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Token FCM guardado en servidor');
      } else {
        debugPrint('⚠️ Error al guardar token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error al guardar token FCM: $e');
    }
  }

  static Future<void> _mostrarNotificacionLocal(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'shopia_channel',
      'Notificaciones Shopia',
      channelDescription: 'Canal para notificaciones de Shopia',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Shopia',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }
}
