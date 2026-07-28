import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';

import '../create/create_post_screen.dart';
import '../create/view_realm_screen.dart';

class _StreamTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _StreamTab({
    required this.label,
    this.selected = false,
  });

  IconData get _icon {
    switch (label) {
      case 'For You':
        return Icons.auto_awesome_rounded;
      case 'Following':
        return Icons.people_alt_outlined;
      case 'Fresh':
        return Icons.bolt_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF38BDF8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : const Color(0xFFE5E3ED),
          width: 1.1,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.20),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 220),
            child: Icon(
              _icon,
              size: 15,
              color: selected
                  ? Colors.white
                  : const Color(0xFF777783),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xFF555560),
                fontSize: 11.5,
                fontWeight: selected
                    ? FontWeight.w900
                    : FontWeight.w700,
                letterSpacing: selected ? 0.15 : 0,
              ),
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 15,
            ),
          ],
        ],
      ),
    );
  }
}

class _VibeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String viewers;

  const _VibeCard({
    required this.emoji,
    required this.title,
    required this.viewers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 25)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.visibility_rounded,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                '$viewers viewing',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _createHubOpen = false;

  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<PostModel>> get _postsStream =>
      _firestoreService.getPosts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Vɪᴇᴡɢʀᴀᴍ ✦',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7,
                              color: Color(0xFF15151B),
                            ),
                          ),
                        ),
                        _topIcon(
                          Icons.notifications_none_rounded,
                          onTap: () {},
                          accent: const Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 8),
                        _topIcon(
                          Icons.person_outline_rounded,
                          onTap: () {},
                          accent: const Color(0xFF38BDF8),
                          profile: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Your World. Your View.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8A8A96),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Good evening 👋',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17171D),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'What caught your view today?',
                      style: TextStyle(fontSize: 14, color: Color(0xFF777783)),
                    ),

                    const SizedBox(height: 17),

                    _discoverPortal(context),

                    const SizedBox(height: 28),

                    const Text(
                      'MOMENTS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: Color(0xFF25252D),
                      ),
                    ),

                    const SizedBox(height: 13),

                    SizedBox(
                      height: 142,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _StoryCard(name: 'Your View', isYourStory: true),
                          _StoryCard(name: 'Aisha', emoji: '🌸'),
                          _StoryCard(name: 'Arman', emoji: '🌆', isLive: true),
                          _StoryCard(name: 'Sara', emoji: '🌿'),
                          _StoryCard(name: 'Zoya', emoji: '✨'),
                          _StoryCard(name: 'Ali', emoji: '🏙️'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        '←  Swipe to explore views  →',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9999A4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'LIVE VIBES',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: Color(0xFF25252D),
                      ),
                    ),

                    const SizedBox(height: 13),

                    SizedBox(
                      height: 118,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _VibeCard(
                            emoji: '🌆',
                            title: 'Night Photography',
                            viewers: '1.8K',
                          ),
                          _VibeCard(
                            emoji: '🎵',
                            title: 'Music Lovers',
                            viewers: '842',
                          ),
                          _VibeCard(
                            emoji: '🎨',
                            title: 'Creative Corner',
                            viewers: '526',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _MoodChip(icon: '🎭', label: 'Chill', selected: true),
                          _MoodChip(icon: '🔥', label: 'Trending'),
                          _MoodChip(icon: '🎨', label: 'Creative'),
                          _MoodChip(icon: '🌍', label: 'Explore'),
                          _MoodChip(icon: '😂', label: 'Fun'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 42,
                      child: Row(
                        children: const [
                          Expanded(
                            child: _StreamTab(label: 'For You', selected: true),
                          ),
                          Expanded(child: _StreamTab(label: 'Following')),
                          Expanded(child: _StreamTab(label: 'Fresh')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "✦ VIEWSTREAM",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.05,
                              color: Color(0xFF25252D),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const _TuneViewSheet(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE4E2EC),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.045),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 17,
                                    color: Color(0xFF7C3AED),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'TUNE VIEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF555560),
                                      letterSpacing: 0.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),
                  ],
                ),
              ),
            ),

            StreamBuilder<List<PostModel>>(
              stream: _postsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load posts: ${snapshot.error}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: Text(
                          'No views yet. Create your first View! ✨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];

                      return PostCard(
                        postId: post.id,
                        user: 'Viewgram User',
                        caption: post.text,
                        imageUrl: post.imageUrl,
                        videoUrl: post.videoUrl,
                      );
                    },
                    childCount: posts.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),

      floatingActionButton: _CreateHub(
        open: _createHubOpen,
        onToggle: () {
          setState(() {
            _createHubOpen = !_createHubOpen;
          });
        },
        onPhoto: () {
          setState(() {
            _createHubOpen = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostScreen(),
            ),
          );
        },
        onReel: () async {
          setState(() {
            _createHubOpen = false;
          });

          final picker = ImagePicker();
          final video = await picker.pickVideo(
            source: ImageSource.gallery,
          );

          if (!context.mounted || video == null) return;

          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reel banane ke liye login zaroori hai.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          final realmRef =
              FirebaseFirestore.instance.collection('realms').doc();

          await realmRef.set({
            'creatorId': user.uid,
            'videoPath': video.path,
            'createdAt': FieldValue.serverTimestamp(),
            'type': 'reel',
            'status': 'draft',
          });

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewRealmScreen(
                videoPath: video.path,
                realmId: realmRef.id,
              ),
            ),
          );
        },
        onStory: () {
          setState(() {
            _createHubOpen = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Story View is coming soon ✨'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  static Widget _topIcon(
    IconData icon, {
    required VoidCallback onTap,
    required Color accent,
    bool profile = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(profile ? 17 : 14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(profile ? 17 : 14),
            border: Border.all(
              color: accent.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: accent,
            size: profile ? 21 : 22,
          ),
        ),
      ),
    );
  }

  static Widget _discoverPortal(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF38BDF8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              SizedBox(width: 17),
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 23,
              ),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIEW PORTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Discover people & moments',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateHub extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onPhoto;
  final VoidCallback onReel;
  final VoidCallback onStory;

  const _CreateHub({
    required this.open,
    required this.onToggle,
    required this.onPhoto,
    required this.onReel,
    required this.onStory,
  });

  Widget _option({
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE9E7F2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF38BDF8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.35,
                    color: Color(0xFF292932),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.18, 0),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
          child: open
              ? Column(
                  key: const ValueKey("create_options"),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _option(
                      emoji: "📸",
                      label: "PHOTO VIEW",
                      onTap: onPhoto,
                    ),
                    const SizedBox(height: 8),
                    _option(
                      emoji: "🎬",
                      label: "REEL VIEW",
                      onTap: onReel,
                    ),
                    const SizedBox(height: 8),
                    _option(
                      emoji: "⭕",
                      label: "STORY VIEW",
                      onTap: onStory,
                    ),
                    const SizedBox(height: 13),
                  ],
                )
              : const SizedBox.shrink(
                  key: ValueKey("create_closed"),
                ),
        ),
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: open ? 62 : 118,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedRotation(
                  turns: open ? 0.125 : 0,
                  duration: const Duration(milliseconds: 260),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                if (!open) ...[
                  const SizedBox(width: 6),
                  const Text(
                    "VIEW",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String name;
  final String emoji;
  final bool isYourStory;
  final bool isLive;

  const _StoryCard({
    required this.name,
    this.emoji = '👤',
    this.isYourStory = false,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // ✨ Viewgram Create Ring
              Container(
                height: 108,
                width: 102,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: isYourStory
                        ? const [
                            Color(0xFF7C3AED),
                            Color(0xFF38BDF8),
                            Color(0xFF7C3AED),
                          ]
                        : const [
                            Color(0xFFE9D5FF),
                            Color(0xFFBAE6FD),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    if (isYourStory)
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 67,
                          height: 67,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isYourStory
                                  ? const [
                                      Color(0xFFF3E8FF),
                                      Color(0xFFE0F2FE),
                                    ]
                                  : const [
                                      Color(0xFFF8F5FF),
                                      Color(0xFFF0F9FF),
                                    ],
                          ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      ),

                      // 🔴 Pulse LIVE badge
                      if (isLive)
                        Positioned(
                          top: 7,
                          left: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B5C),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF3B5C)
                                      .withValues(alpha: 0.28),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 5,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ✨ Create Ring + button
                      if (isYourStory)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7C3AED),
                                  Color(0xFF38BDF8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
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
                    ],
                  ),
                ),
              ),

              // ✦ Your View mini badge
              if (isYourStory)
                Positioned(
                  top: -7,
                  left: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFF38BDF8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED)
                              .withValues(alpha: 0.18),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '✦ YOUR VIEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isYourStory ? FontWeight.w900 : FontWeight.w700,
              color: isYourStory
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFF303039),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;

  const _MoodChip({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF38BDF8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : const Color(0xFFE4E2EC),
          width: 1.1,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: selected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 220),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF44444E),
              fontSize: 12,
              fontWeight: selected
                  ? FontWeight.w900
                  : FontWeight.w700,
              letterSpacing: selected ? 0.15 : 0,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 14,
            ),
          ],
        ],
      ),
    );
  }
}

class _TuneViewSheet extends StatefulWidget {
  const _TuneViewSheet();

  @override
  State<_TuneViewSheet> createState() => _TuneViewSheetState();
}

class _TuneViewSheetState extends State<_TuneViewSheet> {
  double people = 0.65;
  double creative = 0.55;
  double trending = 0.75;
  double live = 0.40;
  double explore = 0.60;

  String preset = 'Custom';

  void _applyPreset(String value) {
    setState(() {
      preset = value;

      if (value == 'Creative') {
        people = 0.45;
        creative = 1.0;
        trending = 0.60;
        live = 0.35;
        explore = 0.75;
      } else if (value == 'Trending') {
        people = 0.55;
        creative = 0.50;
        trending = 1.0;
        live = 0.70;
        explore = 0.65;
      } else if (value == 'Chill') {
        people = 0.75;
        creative = 0.70;
        trending = 0.25;
        live = 0.20;
        explore = 0.55;
      }
    });
  }

  Widget _tuneRow({
    required String icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 17)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF292932),
                  ),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              activeTrackColor: const Color(0xFF7C3AED),
              inactiveTrackColor: const Color(0xFFE8E6F0),
              thumbColor: const Color(0xFF38BDF8),
              overlayColor: const Color(0xFF7C3AED).withValues(alpha: 0.10),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
            ),
            child: Slider(
              value: value,
              onChanged: (v) {
                setState(() {
                  preset = 'Custom';
                });
                onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetButton({
    required String icon,
    required String label,
  }) {
    final selected = preset == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => _applyPreset(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 7),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFF38BDF8),
                    ],
                  )
                : null,
            color: selected ? null : const Color(0xFFF7F6FA),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : const Color(0xFFE6E4ED),
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF555560),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 680),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAD8E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFF38BDF8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TUNE YOUR VIEW',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                            color: Color(0xFF191920),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Make your feed feel more like you.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF858591),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'QUICK VIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: Color(0xFF777783),
                ),
              ),

              const SizedBox(height: 9),

              Row(
                children: [
                  _presetButton(icon: '🎨', label: 'Creative'),
                  _presetButton(icon: '🔥', label: 'Trending'),
                  _presetButton(icon: '🌙', label: 'Chill'),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'YOUR VIEW MIX',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: Color(0xFF777783),
                ),
              ),

              const SizedBox(height: 10),

              _tuneRow(
                icon: '👥',
                title: 'People',
                value: people,
                onChanged: (v) => people = v,
              ),
              _tuneRow(
                icon: '🎨',
                title: 'Creative',
                value: creative,
                onChanged: (v) => creative = v,
              ),
              _tuneRow(
                icon: '🔥',
                title: 'Trending',
                value: trending,
                onChanged: (v) => trending = v,
              ),
              _tuneRow(
                icon: '🔴',
                title: 'Live',
                value: live,
                onChanged: (v) => live = v,
              ),
              _tuneRow(
                icon: '🌍',
                title: 'Explore',
                value: explore,
                onChanged: (v) => explore = v,
              ),

              const SizedBox(height: 6),

              SizedBox(
                width: double.infinity,
                height: 53,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF38BDF8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED)
                            .withValues(alpha: 0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      '✦  APPLY MY VIEW',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
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

class PostCard extends StatefulWidget {
  final String postId;
  final String user;
  final String caption;
  final String imageUrl;
  final String videoUrl;

  const PostCard({
    super.key,
    required this.postId,
    required this.user,
    required this.caption,
    this.imageUrl = '',
    this.videoUrl = '',
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool liked = false;
  bool loadingLike = false;

  VideoPlayerController? _videoController;
  Future<void>? _videoInitializeFuture;

  String selectedReaction = '';
  bool showReactions = false;

  int feelCount = 0;
  List<Map<String, dynamic>> comments = [];

  int get viewScore {
    final reactionScore = selectedReaction.isNotEmpty ? 5 : 0;
    return (feelCount * 2) + (comments.length * 3) + reactionScore;
  }

  DocumentReference<Map<String, dynamic>> get postRef =>
      _firestore.collection('posts').doc(widget.postId);

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _setupVideo();
  }

  void _setupVideo() {
    final url = widget.videoUrl.trim();

    if (url.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    _videoController = controller;
    _videoInitializeFuture = controller.initialize().then((_) {
      if (!mounted) return;
      controller.setLooping(true);
      setState(() {});
    }).catchError((error) {
      debugPrint('Video initialization error: $error');
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final snapshot = await postRef.get();

      if (!snapshot.exists) {
        await postRef.set({
          'user': widget.user,
          'caption': widget.caption,
          'feelCount': 0,
          'likedBy': <String, dynamic>{},
          'comments': <Map<String, dynamic>>[],
          'createdAt': FieldValue.serverTimestamp(),
        });

        return;
      }

      final data = snapshot.data();

      if (data == null || !mounted) return;

      final savedComments = data['comments'];
      final likedBy = data['likedBy'];

      bool userLiked = false;

      if (currentUserId != null && likedBy is Map) {
        userLiked = likedBy[currentUserId] == true;
      }

      List<Map<String, dynamic>> loadedComments = [];

      if (savedComments is List) {
        loadedComments = savedComments
            .whereType<Map>()
            .map((comment) => Map<String, dynamic>.from(comment))
            .toList();
      }

      setState(() {
        feelCount = (data['feelCount'] as num?)?.toInt() ?? 0;
        liked = userLiked;
        comments = loadedComments;
      });
    } catch (e) {
      debugPrint('Firestore load error: $e');
    }
  }

  Future<void> _toggleLike() async {
    final uid = currentUserId;

    if (uid == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like posts.')),
      );

      return;
    }

    if (loadingLike) return;

    final wasLiked = liked;

    setState(() {
      loadingLike = true;
      liked = !wasLiked;
      feelCount = wasLiked
          ? (feelCount > 0 ? feelCount - 1 : 0)
          : feelCount + 1;
    });

    try {
      final batch = _firestore.batch();

      if (wasLiked) {
        batch.update(postRef, {
          'feelCount': FieldValue.increment(-1),
          'likedBy.$uid': FieldValue.delete(),
        });
      } else {
        batch.update(postRef, {
          'feelCount': FieldValue.increment(1),
          'likedBy.$uid': true,
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Firestore like error: $e');

      if (!mounted) return;

      setState(() {
        liked = wasLiked;
        feelCount = wasLiked ? feelCount + 1 : feelCount - 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update like. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingLike = false;
        });
      }
    }
  }

  Widget _reactionButton(String emoji, String label) {
    final selected = selectedReaction == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReaction = label;
          showReactions = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0E7FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(emoji, style: TextStyle(fontSize: selected ? 25 : 22)),
      ),
    );
  }

  Widget _buildMedia() {
    final videoUrl = widget.videoUrl.trim();
    if (videoUrl.isNotEmpty) {
      final controller = _videoController;
      final future = _videoInitializeFuture;
      if (controller == null || future == null) {
        return const SizedBox(height: 330, child: Center(child: CircularProgressIndicator()));
      }
      return Container(
        height: 330,
        width: double.infinity,
        color: Colors.black,
        child: FutureBuilder<void>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError || !controller.value.isInitialized) {
              return const Center(child: Icon(Icons.video_library_outlined, size: 70, color: Colors.grey));
            }
            return GestureDetector(
              onTap: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
                setState(() {});
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                  if (!controller.value.isPlaying)
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }

    final imageUrl = widget.imageUrl.trim();
    if (imageUrl.isNotEmpty) {
      return Container(
        height: 330,
        width: double.infinity,
        color: Colors.grey[900],
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: 330,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image_outlined, size: 70, color: Colors.grey)),
        ),
      );
    }
    return Container(
      height: 330,
      width: double.infinity,
      color: Colors.grey[900],
      child: const Icon(Icons.image_outlined, size: 90, color: Colors.grey),
    );
  }

  Future<void> _addComment(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    final uid = currentUserId;

    if (uid == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to comment.')));

      return;
    }

    final user = _auth.currentUser;

    final comment = <String, dynamic>{
      'userId': uid,
      'username': user?.displayName ?? widget.user,
      'text': cleanText,
      'createdAt': Timestamp.now(),
    };

    final updatedComments = [...comments, comment];

    setState(() {
      comments = updatedComments;
    });

    try {
      await postRef.update({'comments': updatedComments});
    } catch (e) {
      debugPrint('Firestore comment error: $e');

      if (!mounted) return;

      setState(() {
        if (comments.isNotEmpty) {
          comments = comments.sublist(0, comments.length - 1);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add comment. Try again.')),
      );
    }
  }

  void _openComments() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 15,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                if (comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Text(
                      'No comments yet. Be the first!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        final username =
                            comment['username']?.toString() ?? 'User';

                        final text = comment['text']?.toString() ?? '';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            radius: 18,
                            child: Icon(Icons.person, size: 20),
                          ),
                          title: Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(text),
                        );
                      },
                    ),
                  ),

                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final text = controller.text;

                        if (text.trim().isEmpty) return;

                        controller.clear();

                        await _addComment(text);
                      },
                    ),
                  ),
                  onSubmitted: (value) async {
                    if (value.trim().isEmpty) return;

                    controller.clear();

                    await _addComment(value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(
            widget.user,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        _buildMedia(),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: _toggleLike,
                onLongPress: () {
                  setState(() {
                    showReactions = !showReactions;
                  });
                },
                child: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.black,
                  size: 30,
                ),
              ),

              if (showReactions) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE9E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _reactionButton('❤️', 'Love'),
                      _reactionButton('🔥', 'Fire'),
                      _reactionButton('😂', 'Funny'),
                      _reactionButton('✨', 'Wow'),
                    ],
                  ),
                ),
              ],

              const SizedBox(width: 6),

              Text(
                'Feel $feelCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✦ $viewScore',
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              GestureDetector(
                onTap: _openComments,
                child: Text(
                  '💬 ${comments.length}',
                  style: const TextStyle(fontSize: 22),
                ),
              ),

              const SizedBox(width: 20),

              GestureDetector(
                onTap: () {
                  Share.share('Check out this post on Viewgram 🚀');
                },
                child: const Text('🚀', style: TextStyle(fontSize: 25)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
