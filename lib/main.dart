import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const ViewgramApp());
}

class ViewgramApp extends StatelessWidget {
  const ViewgramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Viewgram',
      theme: ThemeData.dark(),
      home: const WelcomeScreen(),
    );
  }
}
