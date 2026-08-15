import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/story_service.dart';
import '../story/story_upload_screen.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: StoryService.myActiveStories(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            return Column(
              children: [
                _header(docs),
                const SizedBox(height: 6),
                _addMoment(),
                const SizedBox(height: 8),
                _tabs(),
                const SizedBox(height: 8),
                Expanded(child: _tab == 0 ? _momentGrid(docs) : _highlights()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final myStories = docs.where((doc) {
      final uid = doc.data()['userId'];
      return uid == StoryServiceUser.currentUid;
    }).length;

    return SizedBox(
      height: 74,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                ),
                border: Border.all(color: const Color(0xFF7C3AED), width: 2),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Moments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your world. Your view.',
                    style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10),
                  ),
                ],
              ),
            ),
            _stat('$myStories', 'Live'),
            const SizedBox(width: 15),
            _stat('${docs.length}', 'Views'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF71717A), fontSize: 9),
        ),
      ],
    );
  }

  Widget _addMoment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoryUploadScreen()),
          );
        },
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Add Moment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [_tabButton('Moments', 0), _tabButton('Highlights', 1)],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    final active = _tab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                  )
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFFA1A1AA),
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _momentGrid(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) {
      return const Center(
        child: Text(
          'No active moments yet',
          style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 20),
      itemCount: docs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: .78,
      ),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();

        final viewedBy = List<String>.from(data['viewedBy'] ?? []);
        final likedBy = List<String>.from(data['likedBy'] ?? []);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MomentViewerScreen(
                  stories: docs.map((e) {
                    return {'id': e.id, ...e.data()};
                  }).toList(),
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  data['mediaUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xFF1A1A22),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.white24,
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility_rounded,
                          color: Colors.white70,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${viewedBy.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF3B5C),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${likedBy.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _highlights() {
    const items = [
      ('Travel', Icons.flight_takeoff_rounded),
      ('Night', Icons.nightlight_round),
      ('Friends', Icons.people_alt_rounded),
      ('Creative', Icons.auto_awesome_rounded),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];

        return Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A22),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
                  ),
                ),
                child: Icon(item.$2, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                item.$1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF71717A)),
            ],
          ),
        );
      },
    );
  }
}

class StoryServiceUser {
  static String? get currentUid {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}

class MomentViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const MomentViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<MomentViewerScreen> createState() => _MomentViewerScreenState();
}

class _MomentViewerScreenState extends State<MomentViewerScreen> {
  late int _index;
  bool _showLens = false;
  bool _liked = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _storySubscription;
  Map<String, dynamic> _liveStory = {};

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _listenToCurrentStory();
    _markViewed();
  }

  Map<String, dynamic> get _story {
    if (_liveStory.isNotEmpty) {
      return _liveStory;
    }

    return widget.stories[_index];
  }

  void _listenToCurrentStory() {
    _storySubscription?.cancel();

    final id = widget.stories[_index]['id']?.toString();

    if (id == null || id.isEmpty) return;

    _storySubscription = StoryService.story(id).listen((snapshot) {
      if (!snapshot.exists || !mounted) return;

      final data = snapshot.data();

      if (data == null) return;

      final story = <String, dynamic>{'id': snapshot.id, ...data};

      final likedBy = List<String>.from(data['likedBy'] ?? <String>[]);

      final uid = StoryServiceUser.currentUid;

      setState(() {
        _liveStory = story;
        _liked = uid != null && likedBy.contains(uid);
      });
    });
  }

  Future<void> _markViewed() async {
    final id = _story['id'];
    if (id != null) {
      await StoryService.markViewed(id);
    }
  }

  Future<void> _toggleLike() async {
    final id = _story['id']?.toString();

    if (id == null || id.isEmpty) return;

    try {
      await StoryService.toggleLike(id);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not update Like')));
    }
  }

  void _next() {
    if (_index < widget.stories.length - 1) {
      setState(() {
        _index++;
        _liveStory = {};
        _liked = false;
      });

      _listenToCurrentStory();
      _markViewed();
    } else {
      Navigator.pop(context);
    }
  }

  void _previous() {
    if (_index > 0) {
      setState(() {
        _index--;
        _liveStory = {};
        _liked = false;
      });

      _listenToCurrentStory();
      _markViewed();
    }
  }

  @override
  void dispose() {
    _storySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = _story;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPress: () {
          setState(() => _showLens = true);
        },
        onLongPressEnd: (_) {
          setState(() => _showLens = false);
        },
        onTapUp: (details) {
          if (details.localPosition.dx <
              MediaQuery.of(context).size.width / 2) {
            _previous();
          } else {
            _next();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              story['mediaUrl'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(color: const Color(0xFF111116));
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Colors.transparent,
                    Color(0xB3000000),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      children: List.generate(
                        widget.stories.length,
                        (i) => Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i <= _index
                                  ? Colors.white
                                  : Colors.white24,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          child: Icon(Icons.person_rounded, size: 20),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            story['username'] ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 105,
              child: GestureDetector(
                onTap: _toggleLike,
                child: Icon(
                  _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _liked ? const Color(0xFFFF3B5C) : Colors.white,
                  size: 31,
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 60,
              bottom: 34,
              child: Container(
                height: 41,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'Send a reaction...',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
            if (_showLens) _lens(story),
          ],
        ),
      ),
    );
  }

  Widget _lens(Map<String, dynamic> story) {
    final viewedBy = List<String>.from(story['viewedBy'] ?? <String>[]);

    final likedBy = List<String>.from(story['likedBy'] ?? <String>[]);

    return Positioned(
      left: 14,
      right: 14,
      bottom: 150,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: StoryService.viewerProfiles(viewedBy),
        builder: (context, snapshot) {
          final viewers = snapshot.data ?? <Map<String, dynamic>>[];

          return Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xEE15151A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF7C3AED)),
              boxShadow: const [
                BoxShadow(color: Color(0x447C3AED), blurRadius: 20),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF38BDF8),
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Moment Lens',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _metric(
                      Icons.visibility_rounded,
                      '${viewedBy.length}',
                      'Views',
                    ),
                    _metric(
                      Icons.favorite_rounded,
                      '${likedBy.length}',
                      'Likes',
                      red: true,
                    ),
                  ],
                ),
                if (viewers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Viewers',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 39,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewers.length,
                      itemBuilder: (context, index) {
                        final viewer = viewers[index];

                        final id = viewer['id']?.toString() ?? '';

                        final photo = viewer['photoUrl']?.toString() ?? '';

                        final liked = likedBy.contains(id);

                        return Padding(
                          padding: const EdgeInsets.only(right: 9),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 17,
                                backgroundColor: const Color(0xFF27272A),
                                backgroundImage: photo.isNotEmpty
                                    ? NetworkImage(photo)
                                    : null,
                                child: photo.isEmpty
                                    ? const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white54,
                                        size: 18,
                                      )
                                    : null,
                              ),
                              if (liked)
                                Positioned(
                                  right: -4,
                                  bottom: -3,
                                  child: Container(
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3B5C),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF15151A),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.white,
                                      size: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metric(
    IconData icon,
    String value,
    String label, {
    bool red = false,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: red ? const Color(0xFFFF3B5C) : Colors.white70,
            size: 15,
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
