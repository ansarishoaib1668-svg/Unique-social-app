import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/story_service.dart';

import '../create/create_post_screen.dart';
import '../create/view_realm_screen.dart';

class _StreamTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _StreamTab({required this.label, this.selected = false});

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
                colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selected ? Colors.transparent : const Color(0xFFE5E3ED),
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
              color: selected ? Colors.white : const Color(0xFF777783),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF555560),
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
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

  Stream<List<PostModel>> get _postsStream => _firestoreService.getPosts();

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

                    const _ViewGalaxy(),

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
                                    color: Colors.black.withValues(
                                      alpha: 0.045,
                                    ),
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
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
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
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = posts[index];

                    return PostCard(
                      postId: post.id,
                      user: 'Viewgram User',
                      caption: post.text,
                      imageUrl: post.imageUrl,
                      videoUrl: post.videoUrl,
                    );
                  }, childCount: posts.length),
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
          Navigator.of(context).push(

            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        onReel: () async {
          setState(() {
            _createHubOpen = false;
          });

          final picker = ImagePicker();
          final video = await picker.pickVideo(source: ImageSource.gallery);

          if (!mounted || video == null) return;

          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            if (!mounted) return;

            final messenger = ScaffoldMessenger.of(this.context);

            messenger.showSnackBar(
              const SnackBar(
                content: Text('Reel banane ke liye login zaroori hai.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          final realmRef = FirebaseFirestore.instance
              .collection('realms')
              .doc();

          await realmRef.set({
            'creatorId': user.uid,
            'videoPath': video.path,
            'createdAt': FieldValue.serverTimestamp(),
            'type': 'reel',
            'status': 'draft',
          });

          if (!mounted) return;

          Navigator.of(context).push(
              MaterialPageRoute(
              builder: (_) =>
                  ViewRealmScreen(videoPath: video.path, realmId: realmRef.id),
            ),
          );
        },
        onStory: () async {
          setState(() {
            _createHubOpen = false;
          });

          final picker = ImagePicker();

          try {
            final file = await picker.pickMedia();

            if (file == null || !mounted) return;

            final mediaFile = File(file.path);

            final lowerPath = file.path.toLowerCase();

            final isVideo =
                lowerPath.endsWith('.mp4') ||
                lowerPath.endsWith('.mov') ||
                lowerPath.endsWith('.m4v') ||
                lowerPath.endsWith('.webm');

            if (!mounted) return;

            final messenger = ScaffoldMessenger.of(this.context);

            messenger.showSnackBar(
              const SnackBar(
                content: Text('Uploading your Story... ☁️'),
                behavior: SnackBarBehavior.floating,
              ),
            );

            final url = await CloudinaryService.uploadFile(mediaFile);

            if (!mounted) return;

            await StoryService.createStory(
              mediaUrl: url,
              mediaType: isVideo ? 'video' : 'image',
            );

            if (!mounted) return;

            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text('Story uploaded successfully ✨'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text('Story upload failed: $e'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
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
          child: Icon(icon, color: accent, size: profile ? 21 : 22),
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
              colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
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
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 23),
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
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
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
            border: Border.all(color: const Color(0xFFE9E7F2), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 16)),
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
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: open
              ? Column(
                  key: const ValueKey("create_options"),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _option(emoji: "📸", label: "PHOTO VIEW", onTap: onPhoto),
                    const SizedBox(height: 8),
                    _option(emoji: "🎬", label: "REEL VIEW", onTap: onReel),
                    const SizedBox(height: 8),
                    _option(emoji: "⭕", label: "STORY VIEW", onTap: onStory),
                    const SizedBox(height: 13),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey("create_closed")),
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

class _GalaxyView {
  final String storyId;
  final String userId;
  final String name;
  final String username;
  final String photoUrl;
  final String mediaUrl;
  final String mediaType;
  final String emoji;
  final bool live;

  const _GalaxyView({
    required this.storyId,
    required this.userId,
    required this.name,
    required this.username,
    required this.photoUrl,
    required this.mediaUrl,
    required this.mediaType,
    this.live = false,
    this.emoji = '✨',
  });

  factory _GalaxyView.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return _GalaxyView(
      storyId: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'User',
      username: data['username'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String? ?? '',
      mediaType: data['mediaType'] as String? ?? 'image',
      live: data['live'] as bool? ?? false,
      emoji: data['emoji'] as String? ?? '✨',
    );
  }
}

class _GalaxyUser {
  final String userId;
  final String name;
  final String username;
  final String photoUrl;
  final bool live;
  final List<_GalaxyView> stories;

  const _GalaxyUser({
    required this.userId,
    required this.name,
    required this.username,
    required this.photoUrl,
    required this.live,
    required this.stories,
  });

  _GalaxyView get preview => stories.first;
}

class _ViewGalaxy extends StatefulWidget {
  const _ViewGalaxy({super.key});

  @override
  State<_ViewGalaxy> createState() => _ViewGalaxyState();
}

class _ViewGalaxyState extends State<_ViewGalaxy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int _selected = 0;

  List<_GalaxyUser> _views = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> get _storyStream =>
      FirebaseFirestore.instance
          .collection('stories')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .snapshots();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_views.isEmpty) return;

    _controller.forward(from: 0);

    setState(() {
      _selected = (_selected + 1) % _views.length;
    });
  }

  void _previous() {
    if (_views.isEmpty) return;

    _controller.reverse(from: 1);

    setState(() {
      _selected = (_selected - 1 + _views.length) % _views.length;
    });
  }

  void _openView(_GalaxyUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ViewCanvas(user: user),
    );
  }

  void _createView() {
    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(
        content: Text('Your View creator will open here ✨'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _storyStream,
      builder: (context, snapshot) {
        final allStories =
            snapshot.data?.docs
                .map(_GalaxyView.fromFirestore)
                .where((view) => view.mediaUrl.isNotEmpty)
                .toList() ??
            <_GalaxyView>[];

        // View Galaxy: one circle per user, with all active stories.
        final grouped = <String, List<_GalaxyView>>{};

        for (final story in allStories) {
          final key = story.userId.isNotEmpty ? story.userId : story.storyId;
          grouped.putIfAbsent(key, () => <_GalaxyView>[]).add(story);
        }

        final views = grouped.entries.map((entry) {
          final stories = entry.value;
          return _GalaxyUser(
            userId: stories.first.userId,
            name: stories.first.name,
            username: stories.first.username,
            photoUrl: stories.first.photoUrl,
            live: stories.any((story) => story.live),
            stories: stories,
          );
        }).toList();

        _views = views;

        if (_views.isEmpty) {
          _selected = 0;
        } else if (_selected >= _views.length) {
          _selected = 0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VIEW GALAXY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: Color(0xFF25252D),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < 0) {
                  _next();
                } else if (velocity > 0) {
                  _previous();
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: 255,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 182,
                          height: 182,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF5EEFF), Color(0xFFE7F7FF)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF7C3AED,
                                ).withValues(alpha: 0.12),
                                blurRadius: 35,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        CustomPaint(
                          size: const Size(235, 235),
                          painter: _GalaxyPainter(progress: _controller.value),
                        ),

                        ...List.generate(_views.length, (index) {
                          final baseAngle =
                              (index / _views.length) * math.pi * 2;

                          final angle =
                              baseAngle +
                              (_selected * (math.pi * 2 / _views.length)) +
                              (_controller.value *
                                  (math.pi * 2 / _views.length));

                          const radius = 94.0;

                          final offset = Offset(
                            math.cos(angle) * radius,
                            math.sin(angle) * radius,
                          );

                          return Transform.translate(
                            offset: offset,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selected = index;
                                });
                                _openView(_views[index]);
                              },
                              child: _GalaxyAvatar(
                                view: _views[index],
                                selected: _selected == index,
                              ),
                            ),
                          );
                        }),

                        GestureDetector(
                          onTap: _createView,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'YOUR VIEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Center(
              child: Text(
                '✦ Swipe Galaxy • Tap a View to explore ✦',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF9999A4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GalaxyAvatar extends StatelessWidget {
  final _GalaxyUser view;
  final bool selected;

  const _GalaxyAvatar({required this.view, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: selected ? 70 : 60,
          height: selected ? 70 : 60,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: view.live
                  ? const [Color(0xFFFF3B5C), Color(0xFFFF9F43)]
                  : const [Color(0xFF7C3AED), Color(0xFF38BDF8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF7C3AED,
                ).withValues(alpha: selected ? 0.28 : 0.12),
                blurRadius: selected ? 16 : 8,
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                view.preview.emoji,
                style: TextStyle(fontSize: selected ? 27 : 23),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          view.name,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF303039),
          ),
        ),
        if (view.live)
          const Text(
            '● LIVE',
            style: TextStyle(
              color: Color(0xFFFF3B5C),
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class _GalaxyPainter extends CustomPainter {
  final double progress;

  const _GalaxyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF7C3AED).withValues(alpha: 0.16);

    canvas.drawCircle(center, 94, ringPaint);

    final angle = progress * math.pi * 2;

    final dot = Offset(
      center.dx + math.cos(angle) * 94,
      center.dy + math.sin(angle) * 94,
    );

    final dotPaint = Paint()..color = const Color(0xFF38BDF8);

    canvas.drawCircle(dot, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ViewCanvas extends StatefulWidget {
  final _GalaxyUser user;

  const _ViewCanvas({required this.user});

  @override
  State<_ViewCanvas> createState() => _ViewCanvasState();
}

class _ViewCanvasState extends State<_ViewCanvas> {
  late final PageController _pageController;
  Timer? _storyTimer;
  int _storyIndex = 0;
  double _storyProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        StoryService.markViewed(widget.user.stories[_storyIndex].storyId);
        _startStoryTimer();
      }
    });
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onStoryChanged(int index) {
    _storyTimer?.cancel();

    setState(() {
      _storyIndex = index;
      _storyProgress = 0.0;
    });

    StoryService.markViewed(widget.user.stories[index].storyId);

    _startStoryTimer();
  }

  void _startStoryTimer() {
    _storyTimer?.cancel();

    final story = widget.user.stories[_storyIndex];

    // Video apne playback ke hisaab se chalega.
    if (story.mediaType == 'video') return;

    const tick = Duration(milliseconds: 100);
    const totalTicks = 50;

    var currentTick = 0;

    _storyTimer = Timer.periodic(tick, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      currentTick++;

      setState(() {
        _storyProgress = (currentTick / totalTicks).clamp(0.0, 1.0);
      });

      if (currentTick >= totalTicks) {
        timer.cancel();

        final nextIndex = _storyIndex + 1;

        if (nextIndex >= widget.user.stories.length) {
          Navigator.pop(context);
          return;
        }

        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.user.stories;
    final currentStory = stories[_storyIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white12,
                    backgroundImage: widget.user.photoUrl.isNotEmpty
                        ? NetworkImage(widget.user.photoUrl)
                        : null,
                    child: widget.user.photoUrl.isEmpty
                        ? Text(
                            currentStory.emoji,
                            style: const TextStyle(fontSize: 20),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.user.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 4,
              child: Row(
                children: List.generate(stories.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index < _storyIndex
                            ? Colors.white
                            : index == _storyIndex
                            ? Colors.white.withValues(
                                alpha: _storyProgress.clamp(0.0, 1.0),
                              )
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: stories.length,
                onPageChanged: _onStoryChanged,
                itemBuilder: (context, index) {
                  return _StoryMedia(story: stories[index]);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Row(
                children: [
                  _viewerButton(Icons.favorite_border_rounded, 'React'),
                  const SizedBox(width: 8),
                  _viewerButton(Icons.auto_awesome_rounded, 'ViewBack'),
                  const SizedBox(width: 8),
                  _viewerButton(Icons.share_outlined, 'Share'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewerButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryMedia extends StatefulWidget {
  final _GalaxyView story;

  const _StoryMedia({required this.story});

  @override
  State<_StoryMedia> createState() => _StoryMediaState();
}

class _StoryMediaState extends State<_StoryMedia> {
  VideoPlayerController? _controller;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();

    if (widget.story.mediaType == 'video') {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.story.mediaUrl),
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.play();

      setState(() {});
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _videoError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.story.mediaUrl.isEmpty) {
      return _errorView(Icons.broken_image_outlined);
    }

    if (widget.story.mediaType == 'video') {
      return _buildVideo();
    }

    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 3,
        child: Image.network(
          widget.story.mediaUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
          errorBuilder: (_, __, ___) {
            return _errorView(Icons.broken_image_outlined);
          },
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_videoError) {
      return _errorView(Icons.video_library_outlined);
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: GestureDetector(
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
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),

            AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 180),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(IconData icon) {
    return Center(child: Icon(icon, color: Colors.white54, size: 50));
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
                colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? Colors.transparent : const Color(0xFFE4E2EC),
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
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF44444E),
              fontSize: 12,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
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

  Widget _presetButton({required String icon, required String label}) {
    final selected = preset == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => _applyPreset(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 7),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                  )
                : null,
            color: selected ? null : const Color(0xFFF7F6FA),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFE6E4ED),
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
                  color: selected ? Colors.white : const Color(0xFF555560),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                        colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
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
                      colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                    ),
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.20),
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

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    _videoController = controller;
    _videoInitializeFuture = controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          controller.setLooping(true);
          setState(() {});
        })
        .catchError((error) {
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

      ScaffoldMessenger.of(this.context).showSnackBar(
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

      ScaffoldMessenger.of(this.context).showSnackBar(
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
        return const SizedBox(
          height: 330,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Container(
        height: 330,
        width: double.infinity,
        color: Colors.black,
        child: FutureBuilder<void>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError || !controller.value.isInitialized) {
              return const Center(
                child: Icon(
                  Icons.video_library_outlined,
                  size: 70,
                  color: Colors.grey,
                ),
              );
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
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
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
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 70,
              color: Colors.grey,
            ),
          ),
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

      ScaffoldMessenger.of(this.context).showSnackBar(
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
