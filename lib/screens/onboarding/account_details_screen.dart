import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'interests_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  final String selectedView;
  final String name;
  final String username;

  const AccountDetailsScreen({
    super.key,
    required this.selectedView,
    required this.name,
    required this.username,
  });

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool loading = false;

  String normalizeUsername(String value) {
    return value.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
  }

  Future<void> createAccount() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final username = normalizeUsername(widget.username);

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _message('Please fill all fields.');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _message('Please enter a valid email.');
      return;
    }

    if (password.length < 6) {
      _message('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      _message('Passwords do not match.');
      return;
    }

    setState(() => loading = true);

    final firestore = FirebaseFirestore.instance;
    final usernameRef = firestore.collection('usernames').doc(username);

    try {
      final usernameDoc = await usernameRef.get();

      if (usernameDoc.exists) {
        throw Exception('USERNAME_TAKEN');
      }

      await usernameRef.set({
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      UserCredential credential;

      try {
        credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        await usernameRef.delete();
        rethrow;
      }

      final user = credential.user;

      if (user == null) {
        await usernameRef.delete();
        throw Exception('ACCOUNT_CREATION_FAILED');
      }

      await user.updateDisplayName(widget.name);

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': widget.name,
        'username': username,
        'email': email,
        'viewType': widget.selectedView,
        'photoUrl': null,
        'bio': '',
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
        'interests': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InterestsScreen(
            selectedView: widget.selectedView,
            name: widget.name,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Account creation failed.';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please try again.';
      }

      _message(message);
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('USERNAME_TAKEN')) {
        _message('@$username is already taken.');
      } else {
        _message('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: Color(0xFF8B8B98),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF9F8FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE9E5F2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFF7C3AED),
          width: 1.4,
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
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
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
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
                    '3 of 4',
                    style: TextStyle(
                      color: Color(0xFF8B8B98),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Secure Your Account',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add your login details and you are almost ready.',
                style: TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '@${normalizeUsername(widget.username)}',
                        style: const TextStyle(
                          color: Color(0xFF5B21B6),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: inputDecoration(
                  hint: 'Email address',
                  icon: Icons.mail_outline_rounded,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
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
                      color: const Color(0xFF8B8B98),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your password must contain at least 6 characters.',
                style: TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 30),

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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CREATE ACCOUNT',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
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
