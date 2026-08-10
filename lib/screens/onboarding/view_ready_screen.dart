import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_screen.dart';

class ViewReadyScreen extends StatefulWidget {
  final String name;
  final String selectedView;
  final List<String> interests;

  const ViewReadyScreen({
    super.key,
    required this.name,
    required this.selectedView,
    required this.interests,
  });

  @override
  State<ViewReadyScreen> createState() => _ViewReadyScreenState();
}

class _ViewReadyScreenState extends State<ViewReadyScreen> {
  bool saving = false;

  Future<void> enterViewsta() async {
    setState(() => saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'viewType': widget.selectedView,
          'interests': widget.interests,
          'onboardingCompleted': true,
        });
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not finish setup. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F0FF),
                  border: Border.all(
                    color: const Color(0xFFE4D7FF),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.14),
                      blurRadius: 30,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF7C3AED),
                  size: 58,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Your View Is Ready!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Welcome to VIESTA, ${widget.name}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F8FC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFE9E5F2),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR VIEW',
                      style: TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      widget.selectedView,
                      style: const TextStyle(
                        color: Color(0xFF7C3AED),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.interests.length} interests selected',
                      style: const TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: saving ? null : enterViewsta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    disabledBackgroundColor: const Color(0xFFD8D3E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ENTER VIESTA',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(width: 9),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
