import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
                    onTap: () => _pickReel(context),
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

  static Future<void> _pickReel(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Reel',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose how you want to add your Reel',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1E8FF),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Choose a video from your phone'),
                  onTap: () => Navigator.pop(sheetContext, 'gallery'),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1E8FF),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Record a new Reel'),
                  onTap: () => Navigator.pop(sheetContext, 'camera'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (choice == null || !context.mounted) return;

    final picker = ImagePicker();

    final file = await picker.pickVideo(
      source: choice == 'camera'
          ? ImageSource.camera
          : ImageSource.gallery,
      maxDuration: const Duration(minutes: 10),
    );

    if (file == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewRealmScreen(videoPath: file.path),
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
