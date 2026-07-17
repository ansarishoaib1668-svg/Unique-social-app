import 'package:flutter/material.dart';

void main() {
  runApp(const UniqueSocialApp());
}

class UniqueSocialApp extends StatelessWidget {
  const UniqueSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unique Social App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unique Social"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.people,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              "Welcome to Unique Social App 🚀",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "A new way to connect",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
