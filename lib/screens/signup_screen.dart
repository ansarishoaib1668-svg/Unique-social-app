import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';
import 'home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int step = 0;
  bool loading = false;
  bool usernameChecking = false;
  bool usernameAvailable = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  File? profileImage;

  String normalizeUsername(String value) {
    return value.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> checkUsername() async {
    final username = normalizeUsername(usernameController.text);

    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      if (mounted) {
        setState(() {
          usernameAvailable = false;
          usernameChecking = false;
        });
      }
      return;
    }

    setState(() => usernameChecking = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .get();

      if (!mounted) return;

      setState(() {
        usernameAvailable = !doc.exists;
        usernameChecking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => usernameChecking = false);
      showMessage('Could not check username. Please try again.');
    }
  }

  bool validateUsername() {
    final username = normalizeUsername(usernameController.text);

    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      showMessage(
        'Username must be 3-20 characters using letters, numbers or _',
      );
      return false;
    }

    if (!usernameAvailable) {
      showMessage('Please choose an available username.');
      return false;
    }

    return true;
  }

  bool validatePassword() {
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return false;
    }

    if (password != confirm) {
      showMessage('Passwords do not match.');
      return false;
    }

    return true;
  }

  Future<void> pickProfilePicture() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) return;

      setState(() {
        profileImage = File(image.path);
      });
    } catch (_) {
      showMessage('Could not select the picture.');
    }
  }

  Future<void> createAccount() async {
    if (loading) return;

    final username = normalizeUsername(usernameController.text);
    final password = passwordController.text;

    if (!validateUsername() || !validatePassword()) {
      return;
    }

    setState(() => loading = true);

    final firestore = FirebaseFirestore.instance;
    UserCredential? credential;
    DocumentReference<Map<String, dynamic>>? usernameRef;

    try {
      final internalEmail = '$username@viewsta.app';

      // 1. Create Firebase Auth account first.
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: internalEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('ACCOUNT_CREATION_FAILED');
      }

      // 2. Reserve the username after Auth is signed in.
      usernameRef = firestore.collection('usernames').doc(username);

      final existing = await usernameRef.get();

      if (existing.exists) {
        await user.delete();
        throw Exception('USERNAME_TAKEN');
      }

      await usernameRef.set({
        'username': username,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Upload profile picture if selected.
      String? photoUrl;

      if (profileImage != null) {
        try {
          photoUrl = await CloudinaryService.uploadFile(profileImage!);
        } catch (_) {
          await usernameRef.delete();
          await user.delete();
          throw Exception('PHOTO_UPLOAD_FAILED');
        }
      }

      // 4. Create user profile.
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Account could not be created.';

      if (e.code == 'email-already-in-use') {
        message = 'This username is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please try again.';
      }

      showMessage(message);
    } catch (e) {
      if (!mounted) return;

      final error = e.toString();

      if (error.contains('USERNAME_TAKEN')) {
        showMessage('@$username is already taken.');
      } else if (error.contains('PHOTO_UPLOAD_FAILED')) {
        showMessage('Profile picture upload failed. Please try again.');
      } else if (error.contains('ACCOUNT_CREATION_FAILED')) {
        showMessage('Account could not be created.');
      } else {
        showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void nextStep() {
    if (step == 0) {
      if (!validateUsername()) return;
      setState(() => step = 1);
      return;
    }

    if (step == 1) {
      if (!validatePassword()) return;
      setState(() => step = 2);
      return;
    }

    createAccount();
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF8B8B98),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F7FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE9E5F2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF7C3AED),
          width: 1.4,
        ),
      ),
    );
  }

  Widget stepIndicator() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index == 2 ? 0 : 6,
            ),
            decoration: BoxDecoration(
              color: index <= step
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFFE8E5EE),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget usernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create a username',
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose a unique username for your Viewsta profile.',
          style: TextStyle(
            color: Color(0xFF71717A),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: usernameController,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onChanged: (_) => checkUsername(),
          decoration: inputDecoration(
            hint: '@username',
            icon: Icons.alternate_email_rounded,
            suffix: usernameChecking
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : usernameAvailable
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF22C55E),
                      )
                    : null,
          ),
        ),
        const SizedBox(height: 10),
        if (usernameAvailable)
          const Text(
            '✓ Username is available',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 22),
        const Text(
          '3–20 characters • letters, numbers and _',
          style: TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget passwordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create your Viewsta Password',
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Keep your password private and easy for you to remember.',
          style: TextStyle(
            color: Color(0xFF71717A),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: passwordController,
          obscureText: hidePassword,
          textInputAction: TextInputAction.next,
          decoration: inputDecoration(
            hint: 'Viewsta Password',
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              onPressed: () {
                setState(() => hidePassword = !hidePassword);
              },
              icon: Icon(
                hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF8B8B98),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: confirmPasswordController,
          obscureText: hideConfirmPassword,
          textInputAction: TextInputAction.done,
          decoration: inputDecoration(
            hint: 'Confirm Password',
            icon: Icons.verified_user_outlined,
            suffix: IconButton(
              onPressed: () {
                setState(
                  () => hideConfirmPassword = !hideConfirmPassword,
                );
              },
              icon: Icon(
                hideConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF8B8B98),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget profilePictureStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add a profile picture',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Add a profile picture to express your new profile.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF71717A),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 42),
        Center(
          child: GestureDetector(
            onTap: pickProfilePicture,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF4F1FA),
                border: Border.all(
                  color: const Color(0xFFE3DDF0),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: profileImage == null
                    ? const Icon(
                        Icons.person_outline_rounded,
                        size: 64,
                        color: Color(0xFFA1A1AA),
                      )
                    : Image.file(
                        profileImage!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: pickProfilePicture,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add picture'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7C3AED),
              side: const BorderSide(
                color: Color(0xFFDCD5EA),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: loading ? null : createAccount,
          child: const Text(
            'Skip for now',
            style: TextStyle(
              color: Color(0xFF71717A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: loading
                        ? null
                        : () {
                            if (step > 0) {
                              setState(() => step--);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'VIEWSTA',
                    style: TextStyle(
                      color: Color(0xFF18181B),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              stepIndicator(),
              const SizedBox(height: 42),
              if (step == 0) usernameStep(),
              if (step == 1) passwordStep(),
              if (step == 2) profilePictureStep(),
              if (step < 2) ...[
                const SizedBox(height: 38),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      disabledBackgroundColor: const Color(0xFFD8D3E5),
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
                          'NEXT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 9),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 26),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      disabledBackgroundColor: const Color(0xFFD8D3E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Your World. Your View.',
                  style: TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 12,
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
