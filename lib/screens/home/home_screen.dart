import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../moments/moments_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../create/create_hub_screen.dart';

enum _VIcon {
  plusBox,
  heart,
  chat,
  comment,
  share,
  bookmark,
  home,
  search,
  reels,
  discover,
  profile,
}

class _ViewstaIcon extends StatelessWidget {
  final _VIcon type;
  final double size;
  final Color color;
  final double stroke;
  final bool filled;

  const _ViewstaIcon(
    this.type, {
    this.size = 28,
    this.color = Colors.black,
    this.stroke = 2.2,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ViewstaIconPainter(
        type: type,
        color: color,
        stroke: stroke,
        filled: filled,
      ),
    );
  }
}

class _ViewstaIconPainter extends CustomPainter {
  final _VIcon type;
  final Color color;
  final double stroke;
  final bool filled;

  _ViewstaIconPainter({
    required this.type,
    required this.color,
    required this.stroke,
    required this.filled,
  });

  Paint _line() {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  Paint _fill() {
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);
    final p = _line();

    switch (type) {
      case _VIcon.plusBox:
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .13, h * .13, w * .74, h * .74),
          Radius.circular(w * .10),
        );
        canvas.drawRRect(r, p);
        canvas.drawLine(Offset(w * .50, h * .30), Offset(w * .50, h * .70), p);
        canvas.drawLine(Offset(w * .30, h * .50), Offset(w * .70, h * .50), p);
        break;

      case _VIcon.heart:
        final path = Path();
        path.moveTo(w * .50, h * .78);
        path.cubicTo(w * .44, h * .73, w * .16, h * .56, w * .16, h * .34);
        path.cubicTo(w * .16, h * .17, w * .35, h * .11, w * .50, h * .27);
        path.cubicTo(w * .65, h * .11, w * .84, h * .17, w * .84, h * .34);
        path.cubicTo(w * .84, h * .56, w * .56, h * .73, w * .50, h * .78);
        path.close();

        canvas.drawPath(path, filled ? _fill() : p);
        break;

      case _VIcon.chat:
        final bubble = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .15, h * .20, w * .70, h * .55),
          Radius.circular(w * .20),
        );
        canvas.drawRRect(bubble, p);

        final tail = Path()
          ..moveTo(w * .35, h * .74)
          ..lineTo(w * .31, h * .87)
          ..lineTo(w * .47, h * .75);
        canvas.drawPath(tail, p);
        break;

      case _VIcon.comment:
        final bubble = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .12, h * .12, w * .76, h * .63),
          Radius.circular(w * .16),
        );
        canvas.drawRRect(bubble, p);

        final tail = Path()
          ..moveTo(w * .30, h * .74)
          ..lineTo(w * .25, h * .89)
          ..lineTo(w * .46, h * .75);
        canvas.drawPath(tail, p);
        break;

      case _VIcon.share:
        final path = Path()
          ..moveTo(w * .12, h * .50)
          ..lineTo(w * .84, h * .16)
          ..lineTo(w * .61, h * .84)
          ..lineTo(w * .48, h * .57)
          ..close();

        canvas.drawPath(path, p);

        canvas.drawLine(Offset(w * .12, h * .50), Offset(w * .48, h * .57), p);
        break;

      case _VIcon.bookmark:
        final path = Path()
          ..moveTo(w * .25, h * .12)
          ..lineTo(w * .75, h * .12)
          ..lineTo(w * .75, h * .87)
          ..lineTo(w * .50, h * .68)
          ..lineTo(w * .25, h * .87)
          ..close();

        canvas.drawPath(path, filled ? _fill() : p);
        break;

      case _VIcon.home:
        final roof = Path()
          ..moveTo(w * .12, h * .47)
          ..lineTo(w * .50, h * .15)
          ..lineTo(w * .88, h * .47);

        final body = Path()
          ..moveTo(w * .22, h * .43)
          ..lineTo(w * .22, h * .84)
          ..lineTo(w * .78, h * .84)
          ..lineTo(w * .78, h * .43);

        if (filled) {
          final fp = _fill();
          canvas.drawPath(roof, fp);
          canvas.drawPath(body, fp);
        } else {
          canvas.drawPath(roof, p);
          canvas.drawPath(body, p);
        }
        break;

      case _VIcon.search:
        canvas.drawCircle(Offset(w * .44, h * .44), w * .27, p);
        canvas.drawLine(Offset(w * .64, h * .64), Offset(w * .84, h * .84), p);
        break;

      case _VIcon.reels:
        final rr = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .14, h * .12, w * .72, h * .76),
          Radius.circular(w * .16),
        );
        canvas.drawRRect(rr, p);

        final play = Path()
          ..moveTo(w * .43, h * .34)
          ..lineTo(w * .43, h * .66)
          ..lineTo(w * .68, h * .50)
          ..close();

        canvas.drawPath(play, p);

        canvas.drawLine(Offset(w * .25, h * .12), Offset(w * .37, h * .30), p);
        canvas.drawLine(Offset(w * .47, h * .12), Offset(w * .59, h * .30), p);
        break;

      case _VIcon.discover:
        final star = Path()
          ..moveTo(c.dx, h * .12)
          ..lineTo(w * .57, h * .40)
          ..lineTo(w * .88, h * .50)
          ..lineTo(w * .57, h * .60)
          ..lineTo(c.dx, h * .88)
          ..lineTo(w * .43, h * .60)
          ..lineTo(w * .12, h * .50)
          ..lineTo(w * .43, h * .40)
          ..close();

        canvas.drawPath(star, p);

        final small = Path()
          ..moveTo(w * .80, h * .08)
          ..lineTo(w * .80, h * .22)
          ..moveTo(w * .73, h * .15)
          ..lineTo(w * .87, h * .15);

        canvas.drawPath(small, p);
        break;

      case _VIcon.profile:
        canvas.drawCircle(Offset(w * .50, h * .32), w * .17, p);

        final shoulders = Path()
          ..moveTo(w * .20, h * .84)
          ..cubicTo(w * .22, h * .62, w * .38, h * .55, w * .50, h * .55)
          ..cubicTo(w * .62, h * .55, w * .78, h * .62, w * .80, h * .84);

        canvas.drawPath(shoulders, p);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ViewstaIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.stroke != stroke ||
        oldDelegate.filled != filled;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const purple = Color(0xFF7C3AED);
  static const text = Color(0xFF111114);
  static const muted = Color(0xFF777781);
  static const border = Color(0xFFE8E8EE);

  final _firestore = FirestoreService();
  late final Stream<List<PostModel>> _postsStream;

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
      height: 82,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
            icon: const _ViewstaIcon(_VIcon.plusBox, size: 32, stroke: 2.3),
          ),

          const SizedBox(width: 4),

          IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const _ViewstaIcon(_VIcon.heart, size: 32, stroke: 2.3),
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
                icon: const _ViewstaIcon(_VIcon.chat, size: 31, stroke: 2.3),
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

        final ids = <String>[];

        for (final doc in docs) {
          final id = doc.data()['userId'];
          if (id is String && id.isNotEmpty && !ids.contains(id)) {
            ids.add(id);
          }
        }

        return Container(
          height: 128,
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: ids.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, index) {
              if (index == 0) {
                return _yourStoryItem();
              }

              return _storyItem(ids[index - 1]);
            },
          ),
        );
      },
    );
  }

  Widget _yourStoryItem() {
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
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFC107),
                        Color(0xFFFF176B),
                        Color(0xFF7C3AED),
                      ],
                    ),
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
                              size: 30,
                            )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: const BoxDecoration(
                      color: Color(0xFF168BFF),
                      shape: BoxShape.circle,
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
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFC107),
                        Color(0xFFFF176B),
                        Color(0xFF7C3AED),
                      ],
                    ),
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
        aspectRatio: 1.42,
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
        aspectRatio: 1.42,
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
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _postHeader(post, isOwn),

          Stack(
            children: [
              if (post.type == 'reel' && post.videoUrl.trim().isNotEmpty)
                _reelPlayer(post)
              else if (image.isNotEmpty)
                AspectRatio(
                  aspectRatio: 1.42,
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
              else if (caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    caption,
                    style: const TextStyle(
                      color: text,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ),

              if (image.isNotEmpty)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .58),
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
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 9, 14, 3),
            child: Row(
              children: [
                _postIcon(
                  _VIcon.heart,
                  liked ? const Color(0xFFFF304F) : text,
                  likes > 0 ? _compact(likes) : '',
                  () => _toggleLike(post),
                  filled: liked,
                ),
                const SizedBox(width: 3),
                _postIcon(
                  _VIcon.comment,
                  text,
                  post.comments.isNotEmpty
                      ? _compact(post.comments.length)
                      : '',
                  () => _comment(post),
                ),
                const SizedBox(width: 3),
                _postIcon(_VIcon.share, text, '', () => _sharePost(post)),
                const Spacer(),
                _postIcon(
                  _VIcon.bookmark,
                  text,
                  '',
                  () => _toggleSave(post),
                  filled: saved,
                ),
              ],
            ),
          ),

          if (likes > 0) _likedBySection(likes),

          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 1, 16, 6),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: text,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: 'Viewsta User ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: caption),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
            child: Text(
              post.comments.isEmpty
                  ? 'View all comments'
                  : 'View all ${post.comments.length} comments',
              style: const TextStyle(color: muted, fontSize: 12.5),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
            child: Text(
              _postTime(post.createdAt),
              style: const TextStyle(color: muted, fontSize: 10.5),
            ),
          ),

          const Divider(height: 1, color: border),
        ],
      ),
    );
  }

  Widget _likedBySection(int likes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 26,
            child: Stack(
              children: [
                _miniAvatar(0),
                Positioned(left: 18, child: _miniAvatar(1)),
                Positioned(left: 36, child: _miniAvatar(2)),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              'Liked by others and ${_compact(likes)} people',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: text, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniAvatar(int index) {
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 16,
        color: index == 0 ? const Color(0xFF777781) : const Color(0xFF9999A3),
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

        final verified = data['verified'] == true || data['isVerified'] == true;

        final location =
            data['location'] is String &&
                (data['location'] as String).trim().isNotEmpty
            ? (data['location'] as String).trim()
            : 'India';

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFC107), Color(0xFFFF176B), purple],
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
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (verified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF1597F5),
                            size: 17,
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
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 11.5,
                            ),
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
                constraints: const BoxConstraints(minWidth: 34),
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
    _VIcon icon,
    Color color,
    String count,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ViewstaIcon(
              icon,
              color: color,
              size: 28,
              stroke: 2.25,
              filled: filled,
            ),
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

  Future<void> _sharePost(PostModel post) async {
    final text = post.text.trim();

    try {
      await Share.share(
        text.isEmpty
            ? 'Check out this post on Viewsta'
            : '$text\n\nShared from Viewsta',
      );
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
        height: 82,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8E8EE), width: 0.8)),
        ),
        child: Row(
          children: [
            _navItem(_VIcon.home, 'Home', 0),
            _navItem(_VIcon.search, 'Search', 1),
            _navItem(_VIcon.reels, 'Reels', 2),
            _navItem(_VIcon.discover, 'Discover', 3),
            _navItem(_VIcon.profile, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(_VIcon icon, String label, int index) {
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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _ViewstaIcon(
                    icon,
                    size: active ? 29 : 27,
                    stroke: 2.25,
                    filled: active && index == 0,
                  ),
                  if (index == 3)
                    Positioned(
                      right: -3,
                      top: -3,
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
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: text,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
