import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _streamTab = 0;
  final FirestoreService _firestoreService = FirestoreService();

  static const Color purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _topHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _momentsSection(),
                    const SizedBox(height: 18),
                    _viewstreamSection(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _bottomNavigation(),
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
              margin: const EdgeInsets.only(left: 20),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(14),
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
                size: 21,
              ),
            ),
          ),

          const Text(
            'Viewsta',
            style: TextStyle(
              color: purple,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
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
                    fontSize: 21,
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


  Widget _viewstreamSection() {
    const tabs = ['For You', 'Following', 'Fresh'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final selected = _streamTab == index;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _streamTab = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: selected
                              ? purple
                              : const Color(0xFF77737E),
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDE5FF)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: purple,
                  size: 22,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR VIEW',
                        style: TextStyle(
                          color: Color(0xFF17171D),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Personalized highlights will appear here.',
                        style: TextStyle(
                          color: Color(0xFF77737E),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Text(
                'VIEWSTREAM',
                style: TextStyle(
                  color: Color(0xFF17171D),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                tabs[_streamTab],
                style: const TextStyle(
                  color: purple,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_streamTab == 1)
            _streamMessage(
              Icons.people_outline_rounded,
              'Follow creators to build your Following stream.',
            )
          else
            StreamBuilder<List<PostModel>>(
              stream: _firestoreService.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 35),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _streamMessage(
                    Icons.cloud_off_rounded,
                    'Unable to load Viewstream right now.',
                  );
                }

                final posts = snapshot.data ?? const <PostModel>[];

                if (posts.isEmpty) {
                  return _streamMessage(
                    Icons.photo_library_outlined,
                    'No posts yet. Your Viewstream will appear here.',
                  );
                }

                return Column(
                  children: [
                    for (final post in posts) ...[
                      _streamPostCard(post),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _streamMessage(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EFF3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: purple, size: 28),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF77737E),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _streamPostCard(PostModel post) {
    final hasImage = post.imageUrl.trim().isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFF0EFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFFF2ECFF),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: purple,
                    size: 19,
                  ),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'View Creator',
                    style: TextStyle(
                      color: Color(0xFF17171D),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF17171D),
                ),
              ],
            ),
          ),

          if (hasImage)
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _streamMediaFallback();
                },
              ),
            )
          else if (post.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Text(
                post.text,
                style: const TextStyle(
                  color: Color(0xFF25232B),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            )
          else
            _streamMediaFallback(),

          Padding(
            padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
            child: Row(
              children: [
                _streamAction(
                  Icons.favorite_border_rounded,
                  'Glow',
                  () => _firestoreService.likePost(post.id),
                ),
                _streamAction(
                  Icons.chat_bubble_outline_rounded,
                  'Voice',
                  () {},
                ),
                _streamAction(
                  Icons.send_outlined,
                  'Pass',
                  () {},
                ),
                _streamAction(
                  Icons.bookmark_border_rounded,
                  'Vault',
                  () {},
                ),
                _streamAction(
                  Icons.auto_awesome_rounded,
                  'Vibe',
                  () {},
                ),
                const Spacer(),
                Text(
                  '${post.likes}',
                  style: const TextStyle(
                    color: Color(0xFF77737E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _streamMediaFallback() {
    return Container(
      height: 250,
      width: double.infinity,
      color: const Color(0xFFF7F5FA),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: purple,
          size: 42,
        ),
      ),
    );
  }

  Widget _streamAction(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF17171D),
              size: 19,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF77737E),
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFF0F0F3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          _viewstaNavItem(0, 'Home'),
          _viewstaNavItem(1, 'Reels'),
          _viewstaNavItem(2, 'Chat'),
          _viewstaNavItem(3, 'View Pulse'),
          _viewstaNavItem(4, 'Search'),
          _viewstaNavItem(5, 'Profile'),
        ],
      ),
    );
  }

  Widget _viewstaNavItem(int index, String label) {
    final selected = _selectedIndex == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFF2ECFF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _ViewstaNavPainter(
                      type: index,
                      selected: selected,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}


class _ViewstaNavPainter extends CustomPainter {
  final int type;
  final bool selected;

  const _ViewstaNavPainter({
    required this.type,
    required this.selected,
  });

  static const Color purple = Color(0xFF7C3AED);
  static const Color black = Color(0xFF17171D);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = selected ? purple : black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = purple
      ..style = PaintingStyle.fill;

    switch (type) {
      case 0:
        _home(canvas, line);
        break;
      case 1:
        _reels(canvas, line, fill);
        break;
      case 2:
        _chat(canvas, line, fill);
        break;
      case 3:
        _pulse(canvas, line, fill);
        break;
      case 4:
        _search(canvas, line);
        break;
      case 5:
        _profile(canvas, line, fill);
        break;
    }
  }

  void _home(Canvas canvas, Paint line) {
    final path = Path()
      ..moveTo(3, 10)
      ..lineTo(11, 3)
      ..lineTo(19, 10)
      ..lineTo(19, 19)
      ..lineTo(13, 19)
      ..lineTo(13, 13)
      ..lineTo(9, 13)
      ..lineTo(9, 19)
      ..lineTo(3, 19)
      ..close();

    canvas.drawPath(path, line);
  }

  void _reels(Canvas canvas, Paint line, Paint fill) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 3, 18, 16),
        const Radius.circular(5),
      ),
      line,
    );

    final play = Path()
      ..moveTo(9, 7)
      ..lineTo(9, 15)
      ..lineTo(15, 11)
      ..close();

    canvas.drawPath(play, fill);
  }

  void _chat(Canvas canvas, Paint line, Paint fill) {
    final bubble = Path()
      ..moveTo(5, 3)
      ..lineTo(17, 3)
      ..quadraticBezierTo(20, 3, 20, 6)
      ..lineTo(20, 12)
      ..quadraticBezierTo(20, 15, 17, 15)
      ..lineTo(9, 15)
      ..lineTo(5, 19)
      ..lineTo(6, 15)
      ..quadraticBezierTo(2, 15, 2, 12)
      ..lineTo(2, 6)
      ..quadraticBezierTo(2, 3, 5, 3)
      ..close();

    canvas.drawPath(bubble, line);

    canvas.drawCircle(const Offset(8, 9), 1.1, fill);
    canvas.drawCircle(const Offset(11, 9), 1.1, fill);
    canvas.drawCircle(const Offset(14, 9), 1.1, fill);
  }

  void _pulse(Canvas canvas, Paint line, Paint fill) {
    const center = Offset(11, 11);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 19,
        height: 8,
      ),
      line,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 8,
        height: 19,
      ),
      line,
    );

    final star = Path()
      ..moveTo(11, 4)
      ..lineTo(12.7, 9.3)
      ..lineTo(18, 11)
      ..lineTo(12.7, 12.7)
      ..lineTo(11, 18)
      ..lineTo(9.3, 12.7)
      ..lineTo(4, 11)
      ..lineTo(9.3, 9.3)
      ..close();

    canvas.drawPath(star, fill);
  }

  void _search(Canvas canvas, Paint line) {
    canvas.drawCircle(const Offset(9, 9), 6, line);

    canvas.drawLine(
      const Offset(13.5, 13.5),
      const Offset(19, 19),
      line,
    );
  }

  void _profile(Canvas canvas, Paint line, Paint fill) {
    canvas.drawCircle(const Offset(11, 11), 9, line);

    canvas.drawCircle(
      const Offset(11, 8),
      2.4,
      fill,
    );

    final body = Path()
      ..moveTo(6.5, 17)
      ..quadraticBezierTo(7, 12, 11, 12)
      ..quadraticBezierTo(15, 12, 15.5, 17);

    canvas.drawPath(body, fill);

    final sparkle = Path()
      ..moveTo(17, 2)
      ..lineTo(18, 4)
      ..lineTo(20, 5)
      ..lineTo(18, 6)
      ..lineTo(17, 8)
      ..lineTo(16, 6)
      ..lineTo(14, 5)
      ..lineTo(16, 4)
      ..close();

    canvas.drawPath(sparkle, fill);
  }

  @override
  bool shouldRepaint(covariant _ViewstaNavPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.selected != selected;
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
