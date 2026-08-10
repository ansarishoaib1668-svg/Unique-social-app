import 'package:flutter/material.dart';
import 'create_identity_screen.dart';

class ChooseViewScreen extends StatefulWidget {
  const ChooseViewScreen({super.key});

  @override
  State<ChooseViewScreen> createState() => _ChooseViewScreenState();
}

class _ChooseViewScreenState extends State<ChooseViewScreen> {
  String? selectedView;

  final views = const [
    {
      'title': 'Creator',
      'subtitle': 'Share your ideas & creations',
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'title': 'Vibe',
      'subtitle': 'Discover people & moments',
      'icon': Icons.favorite_rounded,
    },
    {
      'title': 'Explorer',
      'subtitle': 'Find something new every day',
      'icon': Icons.explore_rounded,
    },
    {
      'title': 'Everything',
      'subtitle': 'A little bit of everything',
      'icon': Icons.public_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Spacer(),
                  const Text(
                    '1 of 4',
                    style: TextStyle(
                      color: Color(0xFF8B8B98),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Choose Your View',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'How do you want to experience Viewsta?',
                style: TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: ListView.separated(
                  itemCount: views.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final view = views[index];
                    final title = view['title'] as String;
                    final subtitle = view['subtitle'] as String;
                    final icon = view['icon'] as IconData;
                    final selected = selectedView == title;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedView = title;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF5F0FF)
                              : const Color(0xFFF9F8FC),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFFE9E5F2),
                            width: selected ? 1.7 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF38BDF8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Color(0xFF18181B),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFF71717A),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? const Color(0xFF7C3AED)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFFD4D0DD),
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 17,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedView == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateIdentityScreen(
                                selectedView: selectedView!,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    disabledBackgroundColor: const Color(0xFFE3DFEA),
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
