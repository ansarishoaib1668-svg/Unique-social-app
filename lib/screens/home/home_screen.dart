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
      body: const SafeArea(child: SizedBox.expand()),

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
              size: 31,
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
              width: 42,
              height: 32,
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
              height: 32,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    bottom: 1,
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 31,
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
