import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12001F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Viewgram"),
      ),
      body: const Center(
        child: Text(
          "🏠 Welcome to Viewgram",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Button $index pressed"),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: const Color(0xFF1A0A2A),
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "Post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
