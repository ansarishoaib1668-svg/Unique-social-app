import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Viewsta app logo
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.14),
                      blurRadius: 30,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF7C3AED),
                              Color(0xFF38BDF8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 58,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'VIESTA',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your World. Your View.',
                style: TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),

              const Spacer(flex: 3),

              // Create Account
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 9),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C3AED),
                    side: const BorderSide(
                      color: Color(0xFFDDD6FE),
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'LOG IN',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Your world. Your people. Your view.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 12,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
