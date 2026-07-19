import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff141E30),
              Color(0xff243B55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.play_circle_fill_rounded,
              size: 90,
              color: Colors.white,
            ),

            const SizedBox(height: 25),

            const Text(
              "Welcome to Viewgram",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Connect • Share • Discover",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 60),

            SizedBox(
              width: 280,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Login page open hoga
                },
                child: const Text("Login"),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 280,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // Create account page open hoga
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text("Create Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
