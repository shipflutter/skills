import 'package:flutter/material.dart';

import 'src/auth_page.dart';

void main() {
  runApp(const AuthPocApp());
}

class AuthPocApp extends StatelessWidget {
  const AuthPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter POC Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}
