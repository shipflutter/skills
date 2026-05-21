import 'package:flutter/material.dart';

import 'src/score_form.dart';

void main() {
  runApp(const TestSkillsPocApp());
}

class TestSkillsPocApp extends StatelessWidget {
  const TestSkillsPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Test Skills POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ScoreForm(),
    );
  }
}
