import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../create/create_post_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Vɪᴇᴡɢʀᴀᴍ ✦',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
            },
          ),
        ],
      ),

      body: ListView(
        children: const [
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

  bool liked = false;
  int feelCount = 0;
  List<String> comments = [];

  DocumentReference<Map<String, dynamic>> get postRef =>
      _firestore.collection('posts').doc(widget.postId);

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
          'comments': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
        });

        return;
      }

      final data = snapshot.data();

      if (data == null || !mounted) return;

      final savedComments = data['comments'];

      setState(() {
        feelCount = (data['feelCount'] as num?)?.toInt() ?? 0;

        if (savedComments is List) {
          comments = savedComments
              .map((comment) => comment.toString())
              .toList();
        }
      });
    } catch (e) {
      debugPrint('Firestore load error: $e');
    }
  }

  Future<void> _toggleLike() async {
    final newLiked = !liked;
    final newCount = newLiked
        ? feelCount + 1
        : (feelCount > 0 ? feelCount - 1 : 0);

    setState(() {
      liked = newLiked;
      feelCount = newCount;
    });

    try {
      await postRef.update({'feelCount': newCount});
    } catch (e) {
      debugPrint('Firestore like error: $e');

      if (!mounted) return;

      setState(() {
        liked = !newLiked;
        feelCount = newLiked ? (newCount > 0 ? newCount - 1 : 0) : newCount + 1;
      });
    }
  }

  Future<void> _addComment(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    final updatedComments = [...comments, cleanText];

    setState(() {
      comments = updatedComments;
    });

    try {
      await postRef.update({'comments': updatedComments});
    } catch (e) {
      debugPrint('Firestore comment error: $e');

      if (!mounted) return;

      setState(() {
        comments = comments.length > 1
            ? comments.sublist(0, comments.length - 1)
            : [];
      });
    }
  }

  void _openComments() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,
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
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            radius: 18,
                            child: Icon(Icons.person, size: 20),
                          ),
                          title: Text(comments[index]),
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
                      onPressed: () {
                        final text = controller.text;

                        if (text.trim().isEmpty) return;

                        _addComment(text);
                        controller.clear();
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) return;

                    _addComment(value);
                    controller.clear();
                  },
                ),
              ],
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
                child: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.black,
                  size: 30,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                'Feel $feelCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
