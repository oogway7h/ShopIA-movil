import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/auth_controller.dart';
import 'features/login_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'services/firebase_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/apiService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar configuración zombie (rápido)
  await ApiService.cargarConfiguracion();

  // Inicializar Firebase y Stripe en paralelo
  await Future.wait([Firebase.initializeApp(), _initStripe()]);

  // Inicializar Firebase Messaging en segundo plano
  FirebaseMessagingService.inicializar().catchError((e) {
    debugPrint('⚠️ Error inicializando FCM: $e');
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future<void> _initStripe() async {
  Stripe.publishableKey =
      'pk_test_51SCTlD0SS1LFGLIhL9jWlhw7cTgF5qfZaziM3jBJEFgrOE9MCMs6nvnekjUofs8OoTPdvXXy7WsI5JAgRza3bDTH00FB3CcphL';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: MaterialApp(
        title: 'Shopia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'ES')],
        home: const LoginPage(),
      ),
    );
  }
}
