import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../create/create_post_screen.dart';

class _StreamTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _StreamTab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF7C3AED) : const Color(0xFFF0EFF5),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF666672),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

                    const Row(
                      children: [
                        Expanded(
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
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: Color(0xFF777783),
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildListDelegate(const [
                PostCard(
                  postId: 'welcome_post',
                  user: 'Shaad',
                  caption: 'Welcome to Viewgram 🚀',
                ),
                PostCard(
                  postId: 'creator_post',
                  user: 'Creator',
                  caption: 'Share your moments ✨',
                ),
                PostCard(
                  postId: 'developer_post',
                  user: 'Developer',
                  caption: 'Building social world 🌎',
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'VIEW',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
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
      width: 94,
      margin: const EdgeInsets.only(right: 11),
      child: Column(
        children: [
          Container(
            height: 106,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              gradient: LinearGradient(
                colors: isYourStory
                    ? const [Color(0xFF7C3AED), Color(0xFF38BDF8)]
                    : const [Color(0xFFE9D5FF), Color(0xFFBAE6FD)],
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 34)),
                  ),
                  if (isYourStory)
                    Positioned(
                      right: 7,
                      bottom: 7,
                      child: Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  if (isLive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B5C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF303039),
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
    return Container(
      margin: const EdgeInsets.only(right: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF7C3AED) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF7C3AED) : const Color(0xFFE6E5EC),
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF44444E),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String postId;
  final String user;
  final String caption;

  const PostCard({
    super.key,
    required this.postId,
    required this.user,
    required this.caption,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool liked = false;
  bool loadingLike = false;

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

        Container(
          height: 330,
          width: double.infinity,
          color: Colors.grey[900],
          child: const Icon(Icons.image_outlined, size: 90, color: Colors.grey),
        ),

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
