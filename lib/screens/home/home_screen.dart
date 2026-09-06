import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/viewsta_icons.dart';

import '../create/create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _homeFeed(),
            _placeholder(Icons.search_rounded, 'Search'),
            _placeholder(Icons.movie_creation_outlined, 'Reels'),
            _placeholder(Icons.auto_awesome_rounded, 'Discover'),
            _placeholder(Icons.person_outline_rounded, 'Profile'),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _homeFeed() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _topBar()),
        SliverToBoxAdapter(child: _stories()),
        SliverToBoxAdapter(
          child: Container(
            height: 1,
            color: const Color(0xFFEAEAEA),
          ),
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text('Unable to load posts'),
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No posts yet.\nCreate your first view ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final doc = docs[index];

                  return _PostCard(
                    postId: doc.id,
                    data: doc.data(),
                    firestore: _firestore,
                    auth: _auth,
                  );
                },
                childCount: docs.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 90),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 17, 18, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Viewsta',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -1.7,
              ),
            ),
          ),

          _headerButton(
            icon: Icons.add_box_outlined,
            customType: ViewstaIconType.create,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePostScreen(),
                ),
              );
            },
          ),

          const SizedBox(width: 17),

          Stack(
            clipBehavior: Clip.none,
            children: [
              _headerButton(
                icon: Icons.favorite_border_rounded,
                customType: ViewstaIconType.activity,
                onTap: () {},
              ),
              Positioned(
                right: -2,
                top: -3,
                child: _notificationDot(),
              ),
            ],
          ),

          const SizedBox(width: 17),

          Stack(
            clipBehavior: Clip.none,
            children: [
              _headerButton(
                icon: Icons.chat_bubble_outline_rounded,
                customType: ViewstaIconType.chat,
                onTap: () {},
              ),
              Positioned(
                right: -7,
                top: -7,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3040),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
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

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
    ViewstaIconType? customType,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 34,
        height: 34,
        child: ViewstaIcon(
          type: customType ?? ViewstaIconType.activity,
          size: 30,
        ),
      ),
    );
  }

  Widget _notificationDot() {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFFFF3040),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _stories() {
    return SizedBox(
      height: 171,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('stories').snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.only(
              left: 22,
              right: 12,
              top: 5,
              bottom: 12,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _storyItem(
                name: 'Your story',
                image: _auth.currentUser?.photoURL,
                own: true,
              ),
              ...docs.take(10).map((doc) {
                final data = doc.data();

                return _storyItem(
                  name: data['username']?.toString() ?? 'View',
                  image: data['storyUrl']?.toString() ??
                      data['imageUrl']?.toString(),
                  live: data['isLive'] == true,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _storyItem({
    required String name,
    String? image,
    bool own = false,
    bool live = false,
  }) {
    return Container(
      width: 91,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          SizedBox(
            width: 76,
            height: 92,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFC107),
                        Color(0xFFFF1744),
                        Color(0xFFB000FF),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: _networkImage(
                        image,
                        fallback: Icons.person,
                      ),
                    ),
                  ),
                ),

                if (own)
                  Positioned(
                    right: 0,
                    bottom: 13,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: const Color(0xFF168EFF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                if (live)
                  Positioned(
                    left: 8,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3040),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkImage(
    String? url, {
    IconData fallback = Icons.image_outlined,
  }) {
    if (url == null || url.isEmpty) {
      return Container(
        color: const Color(0xFFF0F0F0),
        alignment: Alignment.center,
        child: Icon(
          fallback,
          size: 32,
          color: const Color(0xFF888888),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          color: const Color(0xFFF0F0F0),
          alignment: Alignment.center,
          child: Icon(
            fallback,
            size: 32,
            color: const Color(0xFF888888),
          ),
        );
      },
    );
  }

  Widget _bottomNavigation() {
    const items = [
      (ViewstaIconType.home, 'Home'),
      (ViewstaIconType.search, 'Search'),
      (ViewstaIconType.reels, 'Reels'),
      (ViewstaIconType.discover, 'Discover'),
      (ViewstaIconType.profile, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 67,
          child: Row(
            children: List.generate(
              items.length,
              (index) {
                final active = index == _currentIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ViewstaIcon(
                          type: items[index].$1,
                          size: 27,
                          color: Colors.black,
                          filled: active,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[index].$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(IconData icon, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 55),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> data;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const _PostCard({
    required this.postId,
    required this.data,
    required this.firestore,
    required this.auth,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool liked = false;
  bool saved = false;
  bool busy = false;

  int commentsCount = 0;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();

    likesCount = _number(widget.data['likes'] ??
        widget.data['feelCount'] ??
        0);

    commentsCount = _number(widget.data['commentsCount'] ?? 0);

    final uid = widget.auth.currentUser?.uid;
    final likedBy = widget.data['likedBy'];

    if (uid != null && likedBy is Map) {
      liked = likedBy[uid] == true;
    }
  }

  int _number(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get _username {
    return widget.data['username']?.toString() ??
        widget.data['user']?.toString() ??
        'Viewsta User';
  }

  String get _location {
    return widget.data['location']?.toString() ?? '';
  }

  String? get _profileImage {
    final value = widget.data['profileImage'] ??
        widget.data['avatar'] ??
        widget.data['userImage'];

    return value?.toString();
  }

  String? get _postImage {
    final value = widget.data['imageUrl'] ??
        widget.data['image'] ??
        widget.data['mediaUrl'];

    return value?.toString();
  }

  String get _caption {
    return widget.data['caption']?.toString() ??
        widget.data['text']?.toString() ??
        '';
  }

  bool get _verified {
    return widget.data['verified'] == true;
  }

  Future<void> _toggleLike() async {
    final uid = widget.auth.currentUser?.uid;

    if (uid == null || busy) return;

    final wasLiked = liked;

    setState(() {
      busy = true;
      liked = !wasLiked;
      likesCount += wasLiked ? -1 : 1;
    });

    try {
      await widget.firestore
          .collection('posts')
          .doc(widget.postId)
          .update({
        'likes': FieldValue.increment(wasLiked ? -1 : 1),
        'likedBy.$uid': wasLiked
            ? FieldValue.delete()
            : true,
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        liked = wasLiked;
        likesCount += wasLiked ? 1 : -1;
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    final uid = widget.auth.currentUser?.uid;

    if (uid == null) return;

    final ref = widget.firestore
        .collection('users')
        .doc(uid)
        .collection('savedPosts')
        .doc(widget.postId);

    try {
      if (saved) {
        await ref.delete();
      } else {
        await ref.set({
          'postId': widget.postId,
          'savedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        setState(() {
          saved = !saved;
        });
      }
    } catch (_) {}
  }

  Future<void> _share() async {
    final text = _caption.isEmpty
        ? 'Check this out on Viewsta'
        : _caption;

    await Share.share(text);
  }

  void _comments() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SizedBox(
              height: 500,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: StreamBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      stream: widget.firestore
                          .collection('posts')
                          .doc(widget.postId)
                          .snapshots(),
                      builder: (_, snapshot) {
                        final data = snapshot.data?.data();
                        final list = data?['comments'];

                        if (list is! List || list.isEmpty) {
                          return const Center(
                            child: Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Color(0xFF888888),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (_, index) {
                            final item = list[index];

                            if (item is! Map) {
                              return const SizedBox();
                            }

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(
                                item['username']?.toString() ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                item['text']?.toString() ?? '',
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded),
                          onPressed: () async {
                            final text = controller.text.trim();
                            final uid = widget.auth.currentUser?.uid;

                            if (text.isEmpty || uid == null) return;

                            await widget.firestore
                                .collection('posts')
                                .doc(widget.postId)
                                .update({
                              'comments': FieldValue.arrayUnion([
                                {
                                  'userId': uid,
                                  'username': widget.auth.currentUser
                                          ?.displayName ??
                                      _username,
                                  'text': text,
                                  'createdAt': Timestamp.now(),
                                }
                              ]),
                              'commentsCount': FieldValue.increment(1),
                            });

                            controller.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _postHeader(),

        if (_postImage != null && _postImage!.isNotEmpty)
          AspectRatio(
            aspectRatio: 0.93,
            child: _networkImage(_postImage!),
          ),

        _actionRow(),

        if (likesCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 5),
            child: Text(
              '${_formatNumber(likesCount)} likes',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$_username ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: _caption),
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: _comments,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 7, 20, 2),
            child: Text(
              'View all $commentsCount comments',
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
              ),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 22),
          child: Text(
            '2 hours ago',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _postHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 15, 11),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFC107),
                  Color(0xFFFF1744),
                  Color(0xFFB000FF),
                ],
              ),
            ),
            child: ClipOval(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: _networkImage(
                    _profileImage,
                    fallback: Icons.person,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _username,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (_verified) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF1597E5),
                        size: 19,
                      ),
                    ],
                  ],
                ),
                if (_location.isNotEmpty)
                  Text(
                    _location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ),

          const Icon(
            Icons.more_vert_rounded,
            size: 28,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _actionRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleLike,
            child: ViewstaIcon(
              type: ViewstaIconType.like,
              size: 31,
              filled: liked,
              color: liked
                  ? const Color(0xFFFF3040)
                  : Colors.black,
            ),
          ),

          const SizedBox(width: 24),

          GestureDetector(
            onTap: _comments,
            child: const ViewstaIcon(
              type: ViewstaIconType.comment,
              size: 31,
            ),
          ),

          const SizedBox(width: 24),

          GestureDetector(
            onTap: _share,
            child: const ViewstaIcon(
              type: ViewstaIconType.share,
              size: 31,
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: _toggleSave,
            child: ViewstaIcon(
              type: ViewstaIconType.save,
              size: 31,
              filled: saved,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }

    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return number.toString();
  }

  Widget _networkImage(
    String? url, {
    IconData fallback = Icons.image_outlined,
  }) {
    if (url == null || url.isEmpty) {
      return Container(
        color: const Color(0xFFF1F1F1),
        child: Icon(
          fallback,
          color: const Color(0xFF999999),
          size: 35,
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) {
        return Container(
          color: const Color(0xFFF1F1F1),
          alignment: Alignment.center,
          child: Icon(
            fallback,
            color: const Color(0xFF999999),
            size: 35,
          ),
        );
      },
    );
  }
}
