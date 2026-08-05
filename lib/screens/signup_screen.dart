import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  String normalizeUsername(String value) {
    return value.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
  }

  Future<void> createAccount() async {
    final name = nameController.text.trim();
    final username = normalizeUsername(usernameController.text);
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username must be 3-20 characters using letters, numbers or _',
          ),
        ),
      );
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => loading = true);

    final firestore = FirebaseFirestore.instance;
    final usernameRef = firestore.collection('usernames').doc(username);

    try {
      // Reserve username atomically.
      await firestore.runTransaction((transaction) async {
        final usernameDoc = await transaction.get(usernameRef);

        if (usernameDoc.exists) {
          throw Exception('USERNAME_TAKEN');
        }

        transaction.set(usernameRef, {
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      UserCredential userCredential;

      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } catch (e) {
        // If Firebase Auth fails, release the reserved username.
        await usernameRef.delete();
        rethrow;
      }

      final user = userCredential.user;

      if (user == null) {
        await usernameRef.delete();
        throw Exception('ACCOUNT_CREATION_FAILED');
      }

      await user.updateDisplayName(name);

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'username': username,
        'email': email,
        'photoUrl': null,
        'bio': '',
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully 🎉')),
      );

      // Signup screen remove karke Home Feed open.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please try again';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      final error = e.toString();

      String message = 'Something went wrong. Please try again.';

      if (error.contains('USERNAME_TAKEN')) {
        message =
            '@$username is already taken. Please choose another username.';
      } else if (error.contains('ACCOUNT_CREATION_FAILED')) {
        message = 'Account could not be created. Please try again.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _viewgramInput({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF777783), fontSize: 14),
      prefixIcon: Icon(icon, color: Color(0xFF8F8F9C), size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF181820),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFF292934)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top branding
              Center(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x557C3AED),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Join Viewsta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              const Center(
                child: Text(
                  'Your World. Your View.',
                  style: TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Create your account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Set up your profile and start sharing your world.',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: _viewgramInput(
                  hint: 'Full name',
                  icon: Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: usernameController,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                style: const TextStyle(color: Colors.white),
                decoration: _viewgramInput(
                  hint: 'Username',
                  icon: Icons.alternate_email_rounded,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                style: const TextStyle(color: Colors.white),
                decoration: _viewgramInput(
                  hint: 'Email address',
                  icon: Icons.mail_outline_rounded,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: _viewgramInput(
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8F8F9C),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: confirmPasswordController,
                obscureText: hideConfirmPassword,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.white),
                decoration: _viewgramInput(
                  hint: 'Confirm password',
                  icon: Icons.verified_user_outlined,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        hideConfirmPassword = !hideConfirmPassword;
                      });
                    },
                    icon: Icon(
                      hideConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8F8F9C),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    disabledBackgroundColor: const Color(0xFF3B3B45),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0xFF292934), thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'VIEWSTA',
                      style: TextStyle(
                        color: Color(0xFF666673),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Color(0xFF292934), thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  'Create your space. Share your view. ✦',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF777783), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
