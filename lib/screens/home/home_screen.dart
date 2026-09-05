import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../chat/chat_screen.dart';
import '../create/create_hub_screen.dart';
import '../moments/moments_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const purple = Color(0xFF7C3AED);
  static const text = Color(0xFF111111);
  static const muted = Color(0xFF777777);
  static const border = Color(0xFFE7E7E7);
  static const blue = Color(0xFF1597F5);
  static const red = Color(0xFFFF304F);

  final FirestoreService _firestore = FirestoreService();

  late final Stream<List<PostModel>> _postsStream;

  final Map<String, bool> _liked = {};
  final Map<String, bool> _saved = {};
  final Map<String, int> _localLikes = {};

  final Map<String, Future<DocumentSnapshot<Map<String, dynamic>>>>
  _userFutures = {};

  int _tab = 0;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _postsStream = _firestore.getPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),

            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _stories()),

                  StreamBuilder<List<PostModel>>(
                    stream: _postsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 250,
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
                        return const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 250,
                            child: Center(
                              child: Text(
                                'Unable to load posts',
                                style: TextStyle(color: muted),
                              ),
                            ),
                          ),
                        );
                      }

                      final posts = snapshot.data ?? <PostModel>[];

                      if (posts.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 250,
                            child: Center(
                              child: Text(
                                'No posts yet',
                                style: TextStyle(color: muted),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _postCard(posts[index]);
                        }, childCount: posts.length),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 95)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return SizedBox(
      height: 78,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 10, 0),
        child: Row(
          children: [
            const Text(
              'Viewsta',
              style: TextStyle(
                color: Colors.black,
                fontSize: 31,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                letterSpacing: -1.8,
              ),
            ),

            const Spacer(),

            _headerButton(
              icon: Icons.add_box_outlined,
              size: 31,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateHubScreen()),
                );
              },
            ),

            const SizedBox(width: 7),

            _headerButton(
              icon: Icons.favorite_border_rounded,
              size: 32,
              onTap: () {},
            ),

            const SizedBox(width: 4),

            Stack(
              clipBehavior: Clip.none,
              children: [
                _headerButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  size: 30,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                ),

                Positioned(
                  right: -1,
                  top: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 43,
        height: 48,
        child: Center(
          child: Icon(icon, color: Colors.black, size: size),
        ),
      ),
    );
  }

  // ============================================================
  // STORIES
  // ============================================================

  Widget _stories() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('stories').snapshots(),
      builder: (context, snapshot) {
        final now = DateTime.now();

        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final created = doc.data()['createdAt'];

          if (created is Timestamp) {
            return now.difference(created.toDate()).inHours < 24;
          }

          return true;
        }).toList();

        final ids = <String>[];

        for (final doc in docs) {
          final uid = doc.data()['userId'];

          if (uid is String && uid.isNotEmpty && !ids.contains(uid)) {
            ids.add(uid);
          }
        }

        return Container(
          height: 148,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: border, width: 0.8)),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(15, 9, 15, 9),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: ids.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 13),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _yourStory();
              }

              return _storyItem(ids[index - 1]);
            },
          ),
        );
      },
    );
  }

  Widget _yourStory() {
    final photo = _user?.photoURL;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateHubScreen()),
        );
      },
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _storyAvatar(photo, hasRing: false),

                Positioned(
                  right: -2,
                  bottom: -1,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            const Text(
              'Your story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storyItem(String uid) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _getUserFuture(uid),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final username =
            data['username'] is String &&
                (data['username'] as String).trim().isNotEmpty
            ? (data['username'] as String).trim()
            : 'User';

        final photo =
            data['photoUrl'] is String &&
                (data['photoUrl'] as String).trim().isNotEmpty
            ? (data['photoUrl'] as String).trim()
            : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MomentsScreen()),
            );
          },
          child: SizedBox(
            width: 78,
            child: Column(
              children: [
                _storyAvatar(photo, hasRing: true),

                const SizedBox(height: 7),

                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: text,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _storyAvatar(String? photo, {required bool hasRing}) {
    Widget avatar = CircleAvatar(
      backgroundColor: const Color(0xFFF0F0F4),
      backgroundImage: photo == null ? null : NetworkImage(photo),
      child: photo == null
          ? const Icon(Icons.person_outline_rounded, color: muted, size: 30)
          : null,
    );

    if (!hasRing) {
      return Container(
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE8E8E8),
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: avatar,
        ),
      );
    }

    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFFFFB300), Color(0xFFFF176B), Color(0xFFB400FF)],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: avatar,
      ),
    );
  }

  // ============================================================
  // POST
  // ============================================================

  Widget _postCard(PostModel post) {
    final liked = _liked[post.id] ?? false;
    final saved = _saved[post.id] ?? false;

    final likes = _localLikes[post.id] ?? post.likes;

    final image = post.imageUrl.trim();
    final video = post.videoUrl.trim();
    final caption = post.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _postHeader(post),

        if (image.isNotEmpty)
          _postImage(image, post)
        else if (video.isNotEmpty)
          _postVideo(video),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 13, 2),
          child: Row(
            children: [
              _actionButton(
                icon: liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: liked ? red : text,
                count: likes > 0 ? _compact(likes) : null,
                onTap: () => _toggleLike(post),
              ),

              const SizedBox(width: 7),

              _actionButton(
                icon: Icons.chat_bubble_outline_rounded,
                color: text,
                count: post.comments.isNotEmpty
                    ? _compact(post.comments.length)
                    : null,
                onTap: () => _comment(post),
              ),

              const SizedBox(width: 7),

              _actionButton(
                icon: Icons.send_outlined,
                color: text,
                count: null,
                onTap: () => _sharePost(post),
              ),

              const Spacer(),

              _actionButton(
                icon: saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: text,
                count: null,
                onTap: () => _toggleSave(post),
              ),
            ],
          ),
        ),

        if (likes > 0) _likedBySection(likes),

        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 7),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: text, fontSize: 14, height: 1.4),
                children: [
                  const TextSpan(
                    text: 'Viewsta User ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: GestureDetector(
            onTap: () => _comment(post),
            child: Text(
              post.comments.isEmpty
                  ? 'View all comments'
                  : 'View all ${post.comments.length} comments',
              style: const TextStyle(color: muted, fontSize: 13),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
          child: Text(
            _postTime(post.createdAt),
            style: const TextStyle(color: muted, fontSize: 11),
          ),
        ),

        const Divider(height: 1, color: border),
      ],
    );
  }

  // ============================================================
  // POST IMAGE
  // ============================================================

  Widget _postImage(String image, PostModel post) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 0.86,
          child: Image.network(
            image,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return Container(
                color: const Color(0xFFF1F1F3),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: muted,
                  size: 38,
                ),
              );
            },
          ),
        ),

        Positioned(
          top: 13,
          right: 13,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .62),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              '1/1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 13,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pageDot(true),
              _pageDot(false),
              _pageDot(false),
              _pageDot(false),
              _pageDot(false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 8 : 7,
      height: active ? 8 : 7,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: .55),
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // VIDEO
  // ============================================================

  Widget _postVideo(String url) {
    return _VideoPost(url: url);
  }

  // ============================================================
  // POST HEADER
  // ============================================================

  Widget _postHeader(PostModel post) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: post.userId.isEmpty ? null : _getUserFuture(post.userId),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final username =
            data['username'] is String &&
                (data['username'] as String).trim().isNotEmpty
            ? (data['username'] as String).trim()
            : 'viewsta_user';

        final photo =
            data['photoUrl'] is String &&
                (data['photoUrl'] as String).trim().isNotEmpty
            ? (data['photoUrl'] as String).trim()
            : null;

        final verified = data['verified'] == true || data['isVerified'] == true;

        final location =
            data['location'] is String &&
                (data['location'] as String).trim().isNotEmpty
            ? (data['location'] as String).trim()
            : 'India';

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF176B), purple],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFF0F0F4),
                    backgroundImage: photo == null ? null : NetworkImage(photo),
                    child: photo == null
                        ? const Icon(Icons.person_outline_rounded, color: muted)
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (verified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: blue,
                            size: 18,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: muted,
                          size: 15,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: text, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 35, minHeight: 45),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? count,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 31),

            if (count != null) ...[
              const SizedBox(width: 6),
              Text(
                count,
                style: const TextStyle(
                  color: text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LIKED BY
  // ============================================================

  Widget _likedBySection(int likes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 1, 16, 7),
      child: Row(
        children: [
          SizedBox(
            width: 67,
            height: 27,
            child: Stack(
              children: [
                _miniAvatar(0),

                Positioned(left: 19, child: _miniAvatar(1)),

                Positioned(left: 38, child: _miniAvatar(2)),
              ],
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              'Liked by others and ${_compact(likes)} people',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: text, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniAvatar(int index) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9EC),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 16,
        color: index == 0 ? const Color(0xFF666666) : const Color(0xFF999999),
      ),
    );
  }

  // ============================================================
  // LIKE
  // ============================================================

  Future<void> _toggleLike(PostModel post) async {
    final uid = _user?.uid;

    if (uid == null) return;

    final next = !(_liked[post.id] ?? false);

    setState(() {
      _liked[post.id] = next;

      _localLikes[post.id] = (post.likes + (next ? 1 : -1)).clamp(0, 1 << 30);
    });

    try {
      await _firestore.setGlow(post.id, uid, next);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _liked[post.id] = !next;
        _localLikes[post.id] = post.likes;
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _toggleSave(PostModel post) async {
    final uid = _user?.uid;

    if (uid == null) return;

    final next = !(_saved[post.id] ?? false);

    setState(() {
      _saved[post.id] = next;
    });

    try {
      await _firestore.setVault(post.id, uid, next);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saved[post.id] = !next;
      });
    }
  }

  // ============================================================
  // SHARE
  // ============================================================

  Future<void> _sharePost(PostModel post) async {
    final caption = post.text.trim();

    try {
      await Share.share(
        caption.isEmpty
            ? 'Check out this post on Viewsta'
            : '$caption\n\nShared from Viewsta',
      );
    } catch (_) {}
  }

  // ============================================================
  // COMMENT
  // ============================================================

  Future<void> _comment(PostModel post) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add comment'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Write something...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final uid = _user?.uid;
    final comment = result?.trim();

    if (uid == null || comment == null || comment.isEmpty) {
      return;
    }

    try {
      await _firestore.addVoiceComment(
        post.id,
        uid,
        _user?.displayName?.trim().isNotEmpty == true
            ? _user!.displayName!.trim()
            : 'Viewsta User',
        comment,
      );
    } catch (_) {}
  }

  // ============================================================
  // USER
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserFuture(String uid) {
    return _userFutures.putIfAbsent(
      uid,
      () => FirebaseFirestore.instance.collection('users').doc(uid).get(),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 79,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: border, width: 0.8)),
        ),
        child: Row(
          children: [
            _navItem(Icons.home_rounded, 'Home', 0),
            _navItem(Icons.search_rounded, 'Search', 1),
            _navItem(Icons.movie_creation_outlined, 'Reels', 2),
            _navItem(Icons.shopping_bag_outlined, 'Shop', 3),
            _navItem(Icons.person_outline_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _tab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _tab = index;
          });

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MomentsScreen()),
            );
          }

          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: 79,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: active ? 30 : 28,
                color: Colors.black,
                weight: active ? 700 : 400,
              ),

              const SizedBox(height: 3),

              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _compact(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    }

    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }

    return '$n';
  }

  String _postTime(DateTime? time) {
    if (time == null) {
      return 'Just now';
    }

    final d = DateTime.now().difference(time);

    if (d.inSeconds < 60) {
      return 'Just now';
    }

    if (d.inMinutes < 60) {
      return '${d.inMinutes}m ago';
    }

    if (d.inHours < 24) {
      return '${d.inHours}h ago';
    }

    if (d.inDays == 1) {
      return 'Yesterday';
    }

    if (d.inDays < 7) {
      return '${d.inDays}d ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }
}

// ================================================================
// VIDEO POST
// ================================================================

class _VideoPost extends StatefulWidget {
  final String url;

  const _VideoPost({required this.url});

  @override
  State<_VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends State<_VideoPost> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 0.86,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF7C3AED),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),

          GestureDetector(
            onTap: () {
              setState(() {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              });
            },
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
