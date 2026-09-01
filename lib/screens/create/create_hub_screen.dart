import 'package:flutter/material.dart';

import 'create_post_screen.dart';
import 'view_realm_screen.dart';

class CreateHubScreen extends StatelessWidget {
  const CreateHubScreen({super.key});

  static const purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Header
            const Text(
              'CREATE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: 46,
              height: 3,
              decoration: BoxDecoration(
                color: CreateHubScreen.purple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 34),

            const Text(
              'What do you want to create?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _CreateItem(
                    icon: Icons.photo_camera_outlined,
                    title: 'Photo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePostScreen(),
                        ),
                      );
                    },
                  ),

                  _CreateItem(
                    icon: Icons.movie_creation_outlined,
                    title: 'Reel',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewRealmScreen(),
                        ),
                      );
                    },
                  ),

                  _CreateItem(
                    icon: Icons.auto_stories_outlined,
                    title: 'Story',
                    onTap: () => _comingSoon(context, 'Story creation'),
                  ),

                  _CreateItem(
                    icon: Icons.edit_note_outlined,
                    title: 'Thought',
                    onTap: () => _comingSoon(context, 'Thought posts'),
                  ),

                  _CreateItem(
                    icon: Icons.people_outline_rounded,
                    title: 'Duo Friends',
                    onTap: () => _comingSoon(context, 'Duo Friends'),
                  ),

                  _CreateItem(
                    icon: Icons.flip_camera_ios_outlined,
                    title: 'Dual Camera',
                    onTap: () => _comingSoon(context, 'Dual Camera'),
                  ),

                  _CreateItem(
                    icon: Icons.radio_button_checked_outlined,
                    title: 'Live',
                    onTap: () => _comingSoon(context, 'Live'),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is coming soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _CreateItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _CreateItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CreateHubScreen.purple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: CreateHubScreen.purple, size: 22),
            ),

            const SizedBox(width: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const Spacer(),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
