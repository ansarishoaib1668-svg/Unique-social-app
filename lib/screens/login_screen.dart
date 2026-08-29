import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_screen.dart';
import 'home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  String normalizeUsername(String value) {
    return value.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> login() async {
    final username = normalizeUsername(usernameController.text);
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      showMessage('Please enter your username and password.');
      return;
    }

    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      showMessage('Please enter a valid username.');
      return;
    }

    setState(() => loading = true);

    try {
      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .get();

      if (!usernameDoc.exists) {
        showMessage('@$username was not found.');
        return;
      }

      final data = usernameDoc.data();

      if (data == null) {
        showMessage('Could not find this account.');
        return;
      }

      String? internalEmail = data['email'] as String?;

      if (internalEmail == null || internalEmail.isEmpty) {
        final uid = data['uid'] as String?;

        if (uid != null && uid.isNotEmpty) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          final userData = userDoc.data();

          if (userData != null) {
            internalEmail = userData['email'] as String?;
          }
        }
      }

      if (internalEmail == null || internalEmail.isEmpty) {
        showMessage(
          'This account needs to be updated before you can log in.',
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: internalEmail,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Please try again.';

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect username or password.';
      } else if (e.code == 'invalid-email') {
        message = 'This account has an invalid login setup.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please try again.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }

      showMessage(message);
    } catch (e) {
      showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
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
        size: 21,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F7FC),
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
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(
                          alpha: 0.13,
                        ),
                        blurRadius: 26,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'VIEWSTA',
                  style: TextStyle(
                    color: Color(0xFF18181B),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Center(
                child: Text(
                  'Your World. Your View.',
                  style: TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 38),

              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Log in to continue to your world.',
                style: TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                style: const TextStyle(
                  color: Color(0xFF18181B),
                ),
                decoration: inputDecoration(
                  hint: '@username',
                  icon: Icons.alternate_email_rounded,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!loading) login();
                },
                style: const TextStyle(
                  color: Color(0xFF18181B),
                ),
                decoration: inputDecoration(
                  hint: 'Viewsta Password',
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

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
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
                              'LOGIN',
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

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Color(0xFF71717A),
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
