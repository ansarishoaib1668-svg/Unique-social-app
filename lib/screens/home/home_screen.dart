import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const Color purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _topHeader(),

            Expanded(child: SingleChildScrollView(child: _momentsSection())),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 88,
          color: Colors.white,
          child: Row(
            children: [
              _navItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
              _navItem(index: 1, icon: Icons.search_rounded, label: 'Search'),
              _navItem(
                index: 2,
                icon: Icons.movie_creation_outlined,
                label: 'Reels',
              ),
              _dualCameraNavItem(),
              _chatNavItem(),
              _navItem(
                index: 5,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topHeader() {
    return SizedBox(
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          const Text(
            'Viewsta',
            style: TextStyle(
              color: purple,
              fontSize: 27,
              fontWeight: FontWeight.w700,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: purple, width: 2),
              ),
              child: CustomPaint(painter: _PulseIconPainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _momentsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Moments',
                  style: TextStyle(
                    color: Color(0xFF17171D),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'See All  ›',
                  style: TextStyle(
                    color: purple,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 125,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _yourMoment(),
                // Real users' Moments will be added here later.
                // No fake names or fake photos.
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _yourMoment() {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: purple.withValues(alpha: 0.65), width: 2),
              color: const Color(0xFFF7F3FF),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: purple.withValues(alpha: 0.12),
                    border: Border.all(
                      color: purple.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: purple,
                    size: 23,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 9,
                  child: Icon(Icons.auto_awesome, color: purple, size: 9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Your Moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: purple,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? purple : const Color(0xFF17171D),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? purple : const Color(0xFF17171D),
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 58 : 0,
              height: selected ? 4 : 0,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }

  Widget _dualCameraNavItem() {
    final bool selected = _selectedIndex == 3;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 26,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 3,
                    child: Container(
                      width: 30,
                      height: 25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected ? purple : const Color(0xFF17171D),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 11,
                        color: selected ? purple : const Color(0xFF17171D),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 25,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: selected ? purple : const Color(0xFF17171D),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 9,
                        color: selected ? purple : const Color(0xFF17171D),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 1,
                    top: -3,
                    child: Icon(Icons.auto_awesome, size: 12, color: purple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dual Camera',
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? purple : const Color(0xFF17171D),
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 58 : 0,
              height: selected ? 4 : 0,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }

  Widget _chatNavItem() {
    final bool selected = _selectedIndex == 4;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 35,
              height: 26,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    bottom: 1,
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 22,
                      color: selected ? purple : const Color(0xFF17171D),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.auto_awesome, size: 13, color: purple),
                  ),
                  Positioned(
                    left: 9,
                    top: 13,
                    child: Row(
                      children: [
                        _chatDot(),
                        const SizedBox(width: 3),
                        _chatDot(),
                        const SizedBox(width: 3),
                        _chatDot(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? purple : const Color(0xFF17171D),
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 58 : 0,
              height: selected ? 4 : 0,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }

  Widget _chatDot() {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(color: purple, shape: BoxShape.circle),
    );
  }
}

class _PulseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(size.width * 0.18, center.dy);
    path.lineTo(size.width * 0.30, center.dy);
    path.lineTo(size.width * 0.38, size.height * 0.34);
    path.lineTo(size.width * 0.46, size.height * 0.66);
    path.lineTo(size.width * 0.54, size.height * 0.42);
    path.lineTo(size.width * 0.62, size.height * 0.58);
    path.lineTo(size.width * 0.70, center.dy);
    path.lineTo(size.width * 0.82, center.dy);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.50),
      2.8,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
