import 'package:flutter/material.dart';

class AppConfig extends StatelessWidget {
  final Widget child;
  const AppConfig({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopia E-commerce',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: child,
    );
  }
}
