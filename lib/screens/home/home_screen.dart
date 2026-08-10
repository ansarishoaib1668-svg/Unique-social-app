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
      body: const SafeArea(
        child: SizedBox.expand(),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 78,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFF0EEF4),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
              ),

              _navItem(
                index: 1,
                icon: Icons.search_rounded,
                label: 'Search',
              ),

              _navItem(
                index: 2,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
              ),

              _reelNavItem(),

              _navItem(
                index: 4,
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
              size: 29,
              color: selected ? purple : const Color(0xFF17171D),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: selected ? purple : const Color(0xFF17171D),
              ),
            ),

            const SizedBox(height: 3),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 6 : 0,
              height: selected ? 6 : 0,
              decoration: const BoxDecoration(
                color: purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reelNavItem() {
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
              width: 31,
              height: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.ondemand_video_outlined,
                    size: 29,
                    color: selected
                        ? purple
                        : const Color(0xFF17171D),
                  ),

                  Positioned(
                    top: 0,
                    right: 2,
                    child: Transform.rotate(
                      angle: -0.18,
                      child: Container(
                        width: 10,
                        height: 2,
                        color: purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Reel',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? purple
                    : const Color(0xFF17171D),
              ),
            ),

            const SizedBox(height: 3),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 6 : 0,
              height: selected ? 6 : 0,
              decoration: const BoxDecoration(
                color: purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
