import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../moments/moments_screen.dart';
import '../story/story_upload_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streamTab = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, bool> _glowStates = {};
  final Map<String, int> _localGlowCounts = {};
  final Set<String> _glowLoading = {};

  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFF000000);
  static const card = Color(0xFF060608);
  static const border = Color(0xFF25252A);
  static const text = Color(0xFFFFFFFF);
  static const muted = Color(0xFFA2A2AB);

  User? get _user => FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _streamTabs()),
                  SliverToBoxAdapter(child: _moments()),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  StreamBuilder<List<PostModel>>(
                    stream: _firestoreService.getPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(36),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: purple,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: _message(
                            Icons.cloud_off_rounded,
                            'Unable to load posts right now.',
                          ),
                        );
                      }

                      final posts = snapshot.data ?? <PostModel>[];

                      for (final post in posts) {
                        if (!_glowStates.containsKey(post.id)) {
                          _loadGlowState(post);
                        }
                      }

                      if (posts.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _message(
                            Icons.photo_library_outlined,
                            'No posts yet.',
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                            child: _postCard(posts[index]),
                          );
                        }, childCount: posts.length),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 92)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 28, 7),
      child: Row(
        children: [
          const Text(
            'viewsta',
            style: TextStyle(
              color: purple,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: text,
                size: 28,
              ),
              Positioned(
                right: -1,
                top: 1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B5C),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _streamTabs() {
    const tabs = ['For You', 'Following', 'Fresh'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 4, 30, 4),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            GestureDetector(
              onTap: () => setState(() => _streamTab = i),
              child: Padding(
                padding: const EdgeInsets.only(top: 7, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tabs[i],
                      style: TextStyle(
                        color: _streamTab == i ? text : const Color(0xFFD1D1D7),
                        fontSize: 15,
                        fontWeight: _streamTab == i
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: _streamTab == i ? 66 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: purple,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i != tabs.length - 1) const SizedBox(width: 38),
          ],
        ],
      ),
    );
  }

  Widget _moments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFF1D1D22), height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 13, 30, 7),
          child: Row(
            children: [
              const Text(
                'Moments',
                style: TextStyle(
                  color: text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MomentsScreen()),
                  );
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) => _moment(isOwn: index == 0),
          ),
        ),
      ],
    );
  }

  Widget _moment({required bool isOwn}) {
    return GestureDetector(
      onTap: () {
        if (isOwn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MomentsScreen()),
          );
        }
      },
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [purple, Color(0xFFDA3DFF), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: background,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF111116),
                      backgroundImage: isOwn && _user?.photoURL != null
                          ? NetworkImage(_user!.photoURL!)
                          : null,
                      child: isOwn && _user?.photoURL != null
                          ? null
                          : const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF777781),
                              size: 28,
                            ),
                    ),
                  ),
                ),
                if (isOwn)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StoryUploadScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          color: purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: text,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              isOwn ? 'Your Moment' : '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: text, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(PostModel post) {
    final hasImage = post.imageUrl.trim().isNotEmpty;
    final comments = post.comments.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _postHeader(post),
          if (hasImage)
            AspectRatio(
              aspectRatio: 1.35,
              child: Image.network(
                post.imageUrl.trim(),
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF060608),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF060608),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFFA2A2AB),
                          size: 38,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Image unavailable',
                          style: TextStyle(
                            color: Color(0xFFA2A2AB),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else if (post.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Text(
                post.text,
                style: const TextStyle(color: text, fontSize: 15, height: 1.4),
              ),
            )
          else
            _mediaFallback(),
          _actions(post),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
            child: Text(
              comments == 0
                  ? 'View all comments'
                  : 'View all $comments comments',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Text(
              _postTime(post.createdAt),
              style: const TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _postTime(DateTime? time) {
    if (time == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _postHeader(PostModel post) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(post.userId)
          .get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final displayName =
            data['displayName'] is String &&
                    (data['displayName'] as String).trim().isNotEmpty
                ? (data['displayName'] as String).trim()
                : 'Viewsta User';

        final username =
            data['username'] is String &&
                    (data['username'] as String).trim().isNotEmpty
                ? (data['username'] as String).trim()
                : 'username';

        final photoUrl =
            data['photoUrl'] is String &&
                    (data['photoUrl'] as String).trim().isNotEmpty
                ? (data['photoUrl'] as String).trim()
                : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: purple,
                    width: 1.6,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF111116),
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF8E8E98),
                          size: 23,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_vert_rounded,
                color: text,
                size: 22,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadGlowState(PostModel post) async {
    final uid = _user?.uid;
    if (uid == null) return;

    try {
      final state = await _firestoreService.getPostActionState(
        post.id,
        uid,
      );

      if (!mounted) return;

      setState(() {
        _glowStates[post.id] = state.glowed;
        _localGlowCounts[post.id] = post.likes;
      });
    } catch (_) {
      // Keep the existing post state if loading fails.
    }
  }

  Widget _actions(PostModel post) {
    final glowed = _glowStates[post.id] ?? false;
    final loading = _glowLoading.contains(post.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      child: Row(
        children: [
          _action(
            glowed ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            '${_localGlowCounts[post.id] ?? post.likes}',
            'Glow',
            loading ? () {} : () => _toggleGlow(post),
            iconColor: glowed ? const Color(0xFFFF3B5C) : text,
          ),
          _action(
            Icons.chat_bubble_outline_rounded,
            '${post.comments.length}',
            'Voice',
            () => _openComments(post),
          ),
          _action(Icons.graphic_eq_rounded, '0', 'Pass', () {}),
          _action(Icons.bookmark_border_rounded, '', 'Vault', () {}),
          _action(Icons.auto_awesome_rounded, '', 'Vibe', () {}),
        ],
      ),
    );
  }

  Future<void> _toggleGlow(PostModel post) async {
    final uid = _user?.uid;

    if (uid == null || _glowLoading.contains(post.id)) return;

    final current = _glowStates[post.id] ?? false;
    final next = !current;

    final oldCount = _localGlowCounts[post.id] ?? post.likes;
    final newCount = next ? oldCount + 1 : oldCount - 1;

    setState(() {
      _glowStates[post.id] = next;
      _localGlowCounts[post.id] = newCount;
      _glowLoading.add(post.id);
    });

    try {
      await _firestoreService.setGlow(post.id, uid, next);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _glowStates[post.id] = current;
        _localGlowCounts[post.id] = oldCount;
      });
    } finally {
      if (mounted) {
        setState(() {
          _glowLoading.remove(post.id);
        });
      }
    }
  }

  void _openComments(PostModel post) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.72,
              minChildSize: 0.45,
              maxChildSize: 0.94,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF101014),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color(0xFF55555F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Voice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(
                        color: Color(0xFF292930),
                        height: 1,
                      ),
                      Expanded(
                        child: post.comments.isEmpty
                            ? const Center(
                                child: Text(
                                  'No voices yet.\nBe the first to say something.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFA2A2AB),
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                itemCount: post.comments.length,
                                itemBuilder: (context, index) {
                                  final comment = post.comments[index];

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      9,
                                      16,
                                      9,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Color(0xFF25252D),
                                          child: Icon(
                                            Icons.person_outline_rounded,
                                            color: Colors.white70,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '@username',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                comment,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            8,
                            12,
                            10 + MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) async {
                                    await _sendVoiceComment(
                                      post,
                                      controller,
                                      setSheetState,
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Add a voice...',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF777780),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF1B1B21),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(22),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await _sendVoiceComment(
                                    post,
                                    controller,
                                    setSheetState,
                                  );
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: purple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Future<void> _sendVoiceComment(
    PostModel post,
    TextEditingController controller,
    StateSetter setSheetState,
  ) async {
    final textValue = controller.text.trim();
    final uid = _user?.uid;

    if (textValue.isEmpty || uid == null) return;

    final name = _user?.displayName?.trim();
    final displayName =
        name == null || name.isEmpty ? 'Viewsta User' : name;

    try {
      await _firestoreService.addVoiceComment(
        post.id,
        uid,
        displayName,
        textValue,
      );

      controller.clear();

      if (mounted) {
        setSheetState(() {});
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to send voice right now.'),
          ),
        );
      }
    }
  }

  Widget _action(
    IconData icon,
    String count,
    String label,
    VoidCallback onTap, {
    Color iconColor = text,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 25),
                  if (count.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Text(
                      count,
                      style: const TextStyle(
                        color: text,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: text,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaFallback() {
    return Container(
      width: double.infinity,
      height: 280,
      color: const Color(0xFF0D0D11),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF5B5B66), size: 38),
      ),
    );
  }

  Widget _message(IconData icon, String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: purple, size: 28),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: background,
          border: Border(top: BorderSide(color: Color(0xFF202026))),
        ),
        child: Row(
          children: [
            _navItem(Icons.home_filled, 'Home', true),
            _navItem(Icons.explore_outlined, 'Explore', false),
            Expanded(
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: text, size: 34),
                ),
              ),
            ),
            _navItem(Icons.chat_bubble_outline_rounded, 'Chat', false),
            _navItem(Icons.person_outline_rounded, 'Profile', false, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? purple : text, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected ? purple : text,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
