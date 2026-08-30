import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';
import '../../services/firestore_service.dart';
import 'edit_photo_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController captionController = TextEditingController();
  final FirestoreService service = FirestoreService();

  File? selectedFile;
  bool uploading = false;
  bool showAdvanced = false;

  Future<void> pickPhoto() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (file == null || !mounted) return;

    final editedFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPhotoScreen(imageFile: File(file.path)),
      ),
    );

    if (editedFile != null && mounted) {
      setState(() {
        selectedFile = editedFile;
      });
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (file == null || !mounted) return;

    final editedFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPhotoScreen(imageFile: File(file.path)),
      ),
    );

    if (editedFile != null && mounted) {
      setState(() {
        selectedFile = editedFile;
      });
    }
  }

  Future<void> createPost() async {
    if (selectedFile == null) {
      _message('Please select a photo first.');
      return;
    }

    setState(() {
      uploading = true;
    });

    try {
      final url = await CloudinaryService.uploadFile(selectedFile!);

      await service.createPost(
        text: captionController.text.trim(),
        imageUrl: url,
        videoUrl: '',
      );

      if (!mounted) return;

      setState(() {
        uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Your View is live!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        uploading = false;
      });

      _message('Could not publish your post.');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: uploading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: uploading ? null : createPost,
            child: const Text(
              'Post',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: uploading
          ? const _UploadingView()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileRow(),
                    const SizedBox(height: 18),

                    _captionBox(),

                    const SizedBox(height: 18),

                    if (selectedFile != null)
                      _selectedPhoto()
                    else
                      _mediaPicker(),

                    const SizedBox(height: 18),

                    _optionTile(
                      icon: Icons.location_on_outlined,
                      title: 'Add Location',
                      subtitle: 'Share where your View happened',
                      onTap: () => _message('Location feature coming next.'),
                    ),

                    _optionTile(
                      icon: Icons.music_note_rounded,
                      title: 'Add Music',
                      subtitle: 'Give your View a soundtrack',
                      onTap: () => _message('Music feature coming next.'),
                    ),

                    _optionTile(
                      icon: Icons.people_outline_rounded,
                      title: 'Audience',
                      subtitle: 'Everyone',
                      onTap: () => _message('Audience settings coming next.'),
                    ),

                    _optionTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'View Enhance',
                      subtitle: 'Make your View stand out',
                      onTap: () => _message('View Enhance coming next.'),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showAdvanced = !showAdvanced;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8DFFF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF7C3AED),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Advanced Settings',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              showAdvanced
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (showAdvanced) ...[
                      const SizedBox(height: 10),
                      _advancedOptions(),
                    ],

                    const SizedBox(height: 24),

                    _bottomHint(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _profileRow() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _currentUserStream(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final name =
            data['displayName']?.toString() ??
            data['name']?.toString() ??
            'Your Name';

        final username = data['username']?.toString() ?? 'username';

        final photoUrl = data['photoUrl']?.toString();

        return Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFEDE4FF),
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF7C3AED))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '@$username',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E8FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.public_rounded,
                    size: 15,
                    color: Color(0xFF7C3AED),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Everyone',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _currentUserStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Widget _captionBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: TextField(
        controller: captionController,
        maxLines: 5,
        minLines: 4,
        decoration: const InputDecoration(
          hintText: "What's on your mind?",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _mediaPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCCBFF)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add a View',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Choose a photo or capture a new one',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _mediaButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: pickPhoto,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _mediaButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: takePhoto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFF7C3AED)),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 13),
        side: const BorderSide(color: Color(0xFFD9C8FF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _selectedPhoto() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            selectedFile!,
            width: double.infinity,
            height: 330,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickPhoto,
                icon: const Icon(Icons.change_circle_outlined),
                label: const Text('Change'),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() {
                  selectedFile = null;
                });
              },
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF1E8FF),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: const Color(0xFF7C3AED)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _advancedOptions() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _SmallSetting(icon: Icons.comment_outlined, text: 'Allow comments'),
          _SmallSetting(icon: Icons.download_outlined, text: 'Allow downloads'),
          _SmallSetting(
            icon: Icons.visibility_outlined,
            text: 'Show View count',
          ),
        ],
      ),
    );
  }

  Widget _bottomHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Make it yours. Add a caption, choose your View and share it with the world.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallSetting extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallSetting({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 19, color: Color(0xFF7C3AED)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(
            Icons.toggle_on_rounded,
            color: Color(0xFF7C3AED),
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _UploadingView extends StatelessWidget {
  const _UploadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Color(0xFF7C3AED),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Publishing your View...',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text('Almost there ✨', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
