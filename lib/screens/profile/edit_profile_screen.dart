import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool _saving = false;

  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFF0F0F12);
  static const card = Color(0xFF1A1A22);
  static const muted = Color(0xFFA1A1AA);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      final data = snapshot.data() ?? {};

      _nameController.text =
          (data['displayName'] as String?)?.trim() ??
          user.displayName ??
          '';

      _usernameController.text =
          (data['username'] as String?)?.trim() ?? '';

      _bioController.text =
          (data['bio'] as String?)?.trim() ?? '';
    } catch (_) {
      _nameController.text = user.displayName ?? '';
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      _showMessage('Name cannot be empty.');
      return;
    }

    if (username.isEmpty) {
      _showMessage('Username cannot be empty.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'displayName': name,
        'username': username,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(name);

      if (!mounted) return;

      _showMessage('Profile updated successfully.');

      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to save profile right now.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveProfile,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: purple,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: purple,
                strokeWidth: 2,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _field(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'Your name',
                ),
                const SizedBox(height: 18),
                _field(
                  label: 'Username',
                  controller: _usernameController,
                  hint: 'username',
                  prefix: '@',
                ),
                const SizedBox(height: 18),
                _field(
                  label: 'Bio',
                  controller: _bioController,
                  hint: 'Tell people about yourself',
                  maxLines: 4,
                  maxLength: 150,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF292930),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: muted,
                        size: 21,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can change your profile information anytime.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? prefix,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: muted),
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
            filled: true,
            fillColor: card,
            counterStyle: const TextStyle(color: muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF292930),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF292930),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: purple,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
