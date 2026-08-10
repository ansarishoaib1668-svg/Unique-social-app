import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'view_ready_screen.dart';

class InterestsScreen extends StatefulWidget {
  final String selectedView;
  final String name;

  const InterestsScreen({
    super.key,
    required this.selectedView,
    required this.name,
  });

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> selectedInterests = {};

  final interests = const [
    ('Music', Icons.music_note_rounded),
    ('Photography', Icons.camera_alt_rounded),
    ('Gaming', Icons.sports_esports_rounded),
    ('Travel', Icons.flight_takeoff_rounded),
    ('Art', Icons.palette_rounded),
    ('Memes', Icons.mood_rounded),
    ('Sports', Icons.sports_soccer_rounded),
    ('Fashion', Icons.checkroom_rounded),
    ('Food', Icons.restaurant_rounded),
    ('Movies', Icons.movie_rounded),
    ('Tech', Icons.devices_rounded),
    ('Trending', Icons.local_fire_department_rounded),
  ];

  Future<void> continueToReady() async {
    if (selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one interest.'),
        ),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'interests': selectedInterests.toList(),
        'viewType': widget.selectedView,
      });
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ViewReadyScreen(
          name: widget.name,
          selectedView: widget.selectedView,
          interests: selectedInterests.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '4 of 4',
                    style: TextStyle(
                      color: Color(0xFF8B8B98),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'What Are You Into?',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Pick the things you want to see more of on Viewsta.',
                style: TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.65,
                  ),
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    final item = interests[index];
                    final title = item.$1;
                    final icon = item.$2;
                    final selected = selectedInterests.contains(title);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            selectedInterests.remove(title);
                          } else {
                            selectedInterests.add(title);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF5F0FF)
                              : const Color(0xFFF9F8FC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFFE9E5F2),
                            width: selected ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: selected
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFF71717A),
                              size: 23,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: selected
                                      ? const Color(0xFF5B21B6)
                                      : const Color(0xFF27272A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF7C3AED),
                                size: 19,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: continueToReady,
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
                        'CONTINUE',
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
