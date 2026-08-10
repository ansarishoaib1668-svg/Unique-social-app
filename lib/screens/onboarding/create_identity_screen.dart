import 'package:flutter/material.dart';
import 'account_details_screen.dart';

class CreateIdentityScreen extends StatefulWidget {
  final String selectedView;

  const CreateIdentityScreen({
    super.key,
    required this.selectedView,
  });

  @override
  State<CreateIdentityScreen> createState() => _CreateIdentityScreenState();
}

class _CreateIdentityScreenState extends State<CreateIdentityScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF8B8B98),
      ),
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
                    '2 of 4',
                    style: TextStyle(
                      color: Color(0xFF8B8B98),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Create Your Identity',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Make your Viewsta profile yours.',
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
                  border: Border.all(
                    color: const Color(0xFFE4D7FF),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your View: ${widget.selectedView}',
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

              const SizedBox(height: 28),

              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  hint: 'Your name',
                  icon: Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: usernameController,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                decoration: inputDecoration(
                  hint: '@username',
                  icon: Icons.alternate_email_rounded,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'You can change your profile details later.',
                style: TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 34),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        usernameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter your name and username.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountDetailsScreen(
                          selectedView: widget.selectedView,
                          name: nameController.text.trim(),
                          username: usernameController.text.trim(),
                        ),
                      ),
                    );
                  },
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
