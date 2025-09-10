import 'package:flutter/material.dart';
import 'package:msu_flutter/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Booking',
      theme: ThemeData(
        useMaterial3: true
      ),
      home: const LoginPage(),
    );
  }
}