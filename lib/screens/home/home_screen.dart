import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../moments/moments_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../create/create_hub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const purple = Color(0xFF7C3AED);
  static const blue = Color(0xFF38BDF8);
  static const text = Color(0xFF111114);
  static const muted = Color(0xFF777781);
  static const border = Color(0xFFE8E8EE);

  final _firestore = FirestoreService();
  late final Stream<List<PostModel>> _postsStream;

  final Map<String, bool> _supported = {};
  final Map<String, bool> _liked = {};
  final Map<String, bool> _saved = {};
  final Map<String, int> _localLikes = {};
  final Map<String, VideoPlayerController> _reelControllers = {};
  int _tab = 0;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _postsStream = _firestore.getPosts();
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
                            height: 220,
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
                            height: 220,
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
                            height: 220,
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
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => _postCard(posts[index]),
                          childCount: posts.length,
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 88)),
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
    return Container(
      height: 72,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Viewsta',
            style: TextStyle(
              color: text,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              letterSpacing: -1.8,
            ),
          ),
          const Spacer(),

          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateHubScreen()),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.add_box_outlined, color: text, size: 29),
          ),

          const SizedBox(width: 4),

          IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: text,
              size: 30,
            ),
          ),

          const SizedBox(width: 2),

          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: text,
                  size: 29,
                ),
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 21,
                  height: 21,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3040),
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
    );
  }

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

        if (docs.isEmpty) return const SizedBox(height: 12);

        final ids = <String>[];
        for (final doc in docs) {
          final id = doc.data()['userId'];
          if (id is String && id.isNotEmpty && !ids.contains(id)) {
            ids.add(id);
          }
        }

        return Container(
          height: 126,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: border, width: .7)),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            scrollDirection: Axis.horizontal,
            itemCount: ids.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _storyItem(ids[index]),
          ),
        );
      },
    );
  }

  Widget _storyItem(String uid) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MomentsScreen()),
          ),
          child: SizedBox(
            width: 78,
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [purple, blue]),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFF1F1F5),
                      backgroundImage: photo == null
                          ? null
                          : NetworkImage(photo),
                      child: photo == null
                          ? const Icon(
                              Icons.person_outline_rounded,
                              color: muted,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: text, fontSize: 10.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reelPlayer(PostModel post) {
    final url = post.videoUrl.trim();

    var controller = _reelControllers[post.id];

    if (controller == null) {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _reelControllers[post.id] = controller;

      controller.initialize().then((_) {
        if (!mounted) return;
        controller!
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        setState(() {});
      });
    }

    if (!controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 4 / 5,
        child: const Center(
          child: CircularProgressIndicator(color: purple, strokeWidth: 2),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (controller!.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
        setState(() {});
      },
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: () {
                  controller!.setVolume(controller.value.volume > 0 ? 0 : 1);
                  setState(() {});
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.value.volume > 0
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            if (!controller.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(PostModel post) {
    final image = post.imageUrl.trim();
    final caption = post.text.trim();
    final likes = _localLikes[post.id] ?? post.likes;
    final liked = _liked[post.id] ?? false;
    final saved = _saved[post.id] ?? false;
    final isOwn = post.userId == _user?.uid;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _postHeader(post, isOwn),
          if (post.type == 'reel' && post.videoUrl.trim().isNotEmpty)
            _reelPlayer(post)
          else if (image.isNotEmpty)
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Image.network(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(
                          color: purple,
                          strokeWidth: 2,
                        ),
                      ),
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF3F3F7),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: muted,
                      size: 42,
                    ),
                  ),
                ),
              ),
            )
          else if (post.videoUrl.trim().isNotEmpty)
            Container(
              height: 280,
              color: const Color(0xFFF3F3F7),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: text,
                  size: 52,
                ),
              ),
            )
          else if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                caption,
                style: const TextStyle(color: text, fontSize: 16, height: 1.45),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 12, 5),
            child: Row(
              children: [
                _postIcon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  liked ? const Color(0xFFFF3B5C) : text,
                  likes > 0 ? _compact(likes) : '',
                  () => _toggleLike(post),
                ),
                _postIcon(
                  Icons.chat_bubble_outline_rounded,
                  text,
                  post.comments.isNotEmpty
                      ? _compact(post.comments.length)
                      : '',
                  () => _comment(post),
                ),
                _postIcon(Icons.send_outlined, text, '', () => _pass(post)),
                const Spacer(),
                _postIcon(
                  saved ? Icons.bookmark : Icons.bookmark_border,
                  text,
                  '',
                  () => _toggleSave(post),
                ),
              ],
            ),
          ),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
              child: Text(
                caption,
                style: const TextStyle(color: text, fontSize: 13, height: 1.4),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              'View ${_compact(likes)}  ·  ${post.comments.isEmpty ? 'View all comments' : 'View all ${post.comments.length} comments'}',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              _postTime(post.createdAt),
              style: const TextStyle(color: muted, fontSize: 10),
            ),
          ),
          const Divider(height: 1, color: border),
        ],
      ),
    );
  }

  final Map<String, Future<DocumentSnapshot<Map<String, dynamic>>>>
  _userFutures = {};

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserFuture(String uid) {
    return _userFutures.putIfAbsent(
      uid,
      () => FirebaseFirestore.instance.collection('users').doc(uid).get(),
    );
  }

  Widget _postHeader(PostModel post, bool isOwn) {
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
        final supported = _supported[post.userId] ?? false;

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFFF0F0F4),
                backgroundImage: photo == null ? null : NetworkImage(photo),
                child: photo == null
                    ? const Icon(Icons.person_outline_rounded, color: muted)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!isOwn)
                OutlinedButton(
                  onPressed: _user == null
                      ? null
                      : () => _toggleSupport(post.userId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: supported ? purple : text,
                    side: BorderSide(
                      color: supported ? purple : text,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    supported ? 'Supporting' : 'Support',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: text,
                  size: 23,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _postIcon(
    IconData icon,
    Color color,
    String count,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30, weight: 1.8),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                count,
                style: const TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSupport(String uid) async {
    final me = _user?.uid;
    if (me == null || uid.isEmpty || me == uid) return;
    final next = !(_supported[uid] ?? false);
    setState(() => _supported[uid] = next);

    final mine = FirebaseFirestore.instance
        .collection('users')
        .doc(me)
        .collection('supporting')
        .doc(uid);
    final theirs = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('supporters')
        .doc(me);

    try {
      if (next) {
        await mine.set({'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
        await theirs.set({
          'uid': me,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await mine.delete();
        await theirs.delete();
      }
    } catch (_) {
      if (mounted) setState(() => _supported[uid] = !next);
    }
  }

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
      if (mounted) {
        setState(() {
          _liked[post.id] = !next;
          _localLikes[post.id] = post.likes;
        });
      }
    }
  }

  Future<void> _toggleSave(PostModel post) async {
    final uid = _user?.uid;
    if (uid == null) return;
    final next = !(_saved[post.id] ?? false);
    setState(() => _saved[post.id] = next);
    try {
      await _firestore.setVault(post.id, uid, next);
    } catch (_) {
      if (mounted) setState(() => _saved[post.id] = !next);
    }
  }

  Future<void> _pass(PostModel post) async {
    final uid = _user?.uid;
    if (uid == null) return;
    try {
      await _firestore.recordPass(post.id, uid);
    } catch (_) {}
  }

  Future<void> _comment(PostModel post) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add comment'),
        content: TextField(
          controller: controller,
          autofocus: true,
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
      ),
    );
    controller.dispose();

    final uid = _user?.uid;
    final comment = result?.trim();
    if (uid == null || comment == null || comment.isEmpty) return;

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

  Widget _bottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8E8EE), width: 0.8)),
        ),
        child: Row(
          children: [
            _navIcon(Icons.home_rounded, 0),
            _navIcon(Icons.search_rounded, 1),
            _navIcon(Icons.ondemand_video_outlined, 2),
            _navIcon(Icons.auto_awesome_outlined, 3),
            _navIcon(Icons.person_outline_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final active = _tab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _tab = index);

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MomentsScreen()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        child: SizedBox(
          height: 78,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.black, size: active ? 31 : 29),

                if (index == 3)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _compact(int n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}M'
      : n >= 1000
      ? '${(n / 1000).toStringAsFixed(1)}K'
      : '$n';

  String _postTime(DateTime? time) {
    if (time == null) return 'Just now';
    final d = DateTime.now().difference(time);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays == 1) return 'Yesterday';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
