import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _floatingIcon(IconData icon, double top, double left, double size) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        icon,
        size: size,
        color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FF),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Stack(
                children: [
                  _floatingIcon(
                    Icons.favorite_rounded,
                    screen.height * 0.20,
                    screen.width * 0.14,
                    25,
                  ),
                  _floatingIcon(
                    Icons.chat_bubble_rounded,
                    screen.height * 0.30,
                    screen.width * 0.78,
                    22,
                  ),
                  _floatingIcon(
                    Icons.share_rounded,
                    screen.height * 0.60,
                    screen.width * 0.12,
                    24,
                  ),
                  _floatingIcon(
                    Icons.play_circle_fill_rounded,
                    screen.height * 0.68,
                    screen.width * 0.78,
                    25,
                  ),
                  _floatingIcon(
                    Icons.camera_alt_rounded,
                    screen.height * 0.78,
                    screen.width * 0.28,
                    23,
                  ),

                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF7C3AED,
                                ).withValues(alpha: 0.16),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7C3AED),
                                        Color(0xFF38BDF8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.visibility_rounded,
                                    color: Colors.white,
                                    size: 58,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Viewsta',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: Color(0xFF18181B),
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'Your World. Your View.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
