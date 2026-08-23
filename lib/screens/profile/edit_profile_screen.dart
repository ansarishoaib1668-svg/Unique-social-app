import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/cloudinary_service.dart';
import '../create/edit_photo_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  final _locationController = TextEditingController();
  final _interestsController = TextEditingController();
  final _websiteController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool _saving = false;

  File? _selectedPhoto;
  String? _photoUrl;
  bool _uploadingPhoto = false;
  double _uploadProgress = 0.0;

  final _picker = ImagePicker();


  static const purple = Color(0xFF7C3AED);
  static const background = Colors.white;
  static const card = Color(0xFFF7F7FA);
  static const muted = Color(0xFF71717A);
  static const text = Color(0xFF18181B);
  static const border = Color(0xFFE4E4E7);

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

      _photoUrl =
          (data['photoUrl'] as String?)?.trim();

      // Existing fields — unchanged.
      _nameController.text =
          (data['displayName'] as String?)?.trim() ??
          user.displayName ??
          '';

      _usernameController.text =
          (data['username'] as String?)?.trim() ?? '';

      _bioController.text =
          (data['bio'] as String?)?.trim() ?? '';

      // New fields.
      _locationController.text =
          (data['location'] as String?)?.trim() ?? '';

      _interestsController.text =
          (data['interests'] as String?)?.trim() ?? '';

      _websiteController.text =
          (data['website'] as String?)?.trim() ?? '';
    } catch (_) {
      _nameController.text = user.displayName ?? '';
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<bool> _isUsernameAvailable(
    String username,
    String currentUid,
  ) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return true;
    }

    return result.docs.first.id == currentUid;
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;

    if (user == null) return;

    // Existing fields — same validation.
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
      final usernameAvailable =
          await _isUsernameAvailable(username, user.uid);

      if (!usernameAvailable) {
        if (mounted) {
          setState(() => _saving = false);
          _showMessage('Username already taken.');
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _showMessage('Unable to check username right now.');
      }
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'displayName': name,
        'username': username,
        'bio': bio,

        // New profile information.
        'location': _locationController.text.trim(),
        'interests': _interestsController.text.trim(),
        'website': _websiteController.text.trim(),

        if (_photoUrl != null && _photoUrl!.isNotEmpty)
          'photoUrl': _photoUrl,

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

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _joinDate() {
    final createdAt = _auth.currentUser?.metadata.creationTime;

    if (createdAt == null) {
      return 'Automatically added';
    }

    return '${createdAt.day.toString().padLeft(2, '0')} '
        '${_month(createdAt.month)} '
        '${createdAt.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();

    _locationController.dispose();
    _interestsController.dispose();
    _websiteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: text,
          onPressed: () => Navigator.pop(context),
        ),

        centerTitle: true,

        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: text,
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
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                40,
              ),
              children: [
                _profilePhoto(),

                const SizedBox(height: 10),

                // Existing fields stay here.
                _field(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'Your name',
                ),

                const SizedBox(height: 16),

                _field(
                  label: 'Username',
                  controller: _usernameController,
                  hint: 'username',
                  prefix: '@',
                ),

                const SizedBox(height: 16),

                _field(
                  label: 'Bio',
                  controller: _bioController,
                  hint: 'Tell people about yourself',
                  maxLines: 4,
                  maxLength: 150,
                ),

                const SizedBox(height: 16),

                // NEW: Location.
                _field(
                  label: 'Location',
                  controller: _locationController,
                  hint: 'City, Country',
                  prefixIcon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 16),

                // NEW: About / Interests.
                _field(
                  label: 'About / Interests',
                  controller: _interestsController,
                  hint: 'Travel • Music • Photography',
                  maxLines: 2,
                  prefixIcon: Icons.auto_awesome_outlined,
                ),

                const SizedBox(height: 16),

                // NEW: Website.
                _field(
                  label: 'Website / Link',
                  controller: _websiteController,
                  hint: 'https://yourwebsite.com',
                  prefixIcon: Icons.link_rounded,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 18),

                // Automatic Join Date.
                _joinCard(),

                const SizedBox(height: 18),

                _infoCard(),
              ],
            ),
    );
  }

  Future<void> _changePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (picked == null || !mounted) return;

      final editedFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (_) => EditPhotoScreen(
            imageFile: File(picked.path),
          ),
        ),
      );

      if (editedFile == null || !mounted) return;

      setState(() {
        _selectedPhoto = editedFile;
        _uploadingPhoto = true;
        _uploadProgress = 0.0;
      });

      final url = await CloudinaryService.uploadFile(
        editedFile,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _photoUrl = url;
        _uploadingPhoto = false;
        _uploadProgress = 1.0;
      });

      _showMessage("Photo uploaded successfully.");
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadingPhoto = false;
          _uploadProgress = 0.0;
        });
        _showMessage("Unable to select or upload photo.");
      }
    }
  }

  Widget _profilePhoto() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_uploadingPhoto)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 4,
                      backgroundColor: const Color(0xFFE9D5FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: card,
                  ),
                  child: ClipOval(
                    child: _selectedPhoto != null
                        ? Image.file(
                            _selectedPhoto!,
                            fit: BoxFit.cover,
                          )
                        : (_photoUrl != null && _photoUrl!.isNotEmpty)
                            ? Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.person_outline_rounded,
                                  color: muted,
                                  size: 42,
                                ),
                              )
                            : const Icon(
                                Icons.person_outline_rounded,
                                color: muted,
                                size: 42,
                              ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          TextButton.icon(
            onPressed: _uploadingPhoto ? null : _changePhoto,
            icon: _uploadingPhoto
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: purple,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: purple,
                  ),
            label: Text(
              _uploadingPhoto ? 'Uploading...' : 'Change Photo',
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _joinCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: purple,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Joined Viewsta',
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Automatically recorded',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            _joinDate(),
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: purple,
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'You can update your profile information anytime.',
              style: TextStyle(
                color: muted,
                fontSize: 13,
                height: 1.4,
              ),
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
    IconData? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,

          style: const TextStyle(
            color: text,
            fontSize: 15,
          ),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              color: muted,
            ),

            prefixText: prefix,

            prefixStyle: const TextStyle(
              color: text,
              fontSize: 15,
            ),

            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    color: muted,
                    size: 20,
                  ),

            filled: true,
            fillColor: card,

            counterStyle: const TextStyle(
              color: muted,
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: border,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: border,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: purple,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
