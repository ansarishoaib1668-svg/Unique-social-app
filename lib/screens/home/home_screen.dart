import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streamTab = 0;
  final FirestoreService _firestoreService = FirestoreService();

  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFF000000);
  static const card = Color(0xFF060608);
  static const border = Color(0xFF25252A);
  static const text = Color(0xFFFFFFFF);
  static const muted = Color(0xFFA2A2AB);

  User? get _user => FirebaseAuth.instance.currentUser;

  String get _displayName {
    final name = _user?.displayName?.trim();
    return (name == null || name.isEmpty) ? 'You' : name;
  }

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

                      if (posts.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _message(
                            Icons.photo_library_outlined,
                            'No posts yet.',
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 0, 14, 12),
                              child: _postCard(posts[index]),
                            );
                          },
                          childCount: posts.length,
                        ),
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
          GestureDetector(
            onTap: _showTuneSheet,
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                Icons.tune_rounded,
                color: text,
                size: 27,
              ),
            ),
          ),
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
                        color: _streamTab == i
                            ? text
                            : const Color(0xFFD1D1D7),
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
              Text(
                'View all',
                style: TextStyle(
                  color: purple,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) => _moment(isOwn: index == 0),
          ),
        ),
      ],
    );
  }

  Widget _moment({required bool isOwn}) {
    return SizedBox(
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
                    colors: [
                      purple,
                      Color(0xFFDA3DFF),
                      Color(0xFFFF9A7A),
                    ],
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
            ],
          ),
          const SizedBox(height: 5),
          Text(
            isOwn ? 'Your Moment' : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: text,
              fontSize: 11,
            ),
          ),
        ],
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
          _postHeader(),
          if (hasImage)
            AspectRatio(
              aspectRatio: 1.35,
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _mediaFallback(),
              ),
            )
          else if (post.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Text(
                post.text,
                style: const TextStyle(
                  color: text,
                  fontSize: 15,
                  height: 1.4,
                ),
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
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Text(
              'Just now',
              style: TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _postHeader() {
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
              border: Border.all(color: purple, width: 1.6),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF111116),
              backgroundImage: _user?.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : null,
              child: _user?.photoURL != null
                  ? null
                  : const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF8E8E98),
                      size: 23,
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
                        _displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF1689F5),
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  '2h ago',
                  style: TextStyle(
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
  }

  Widget _actions(PostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      child: Row(
        children: [
          _action(
            Icons.favorite_border_rounded,
            '${post.likes}',
            'Glow',
            () => _firestoreService.likePost(post.id),
          ),
          _action(
            Icons.chat_bubble_outline_rounded,
            '${post.comments.length}',
            'Voice',
            () {},
          ),
          _action(
            Icons.graphic_eq_rounded,
            '0',
            'Pass',
            () {},
          ),
          _action(
            Icons.bookmark_border_rounded,
            '',
            'Vault',
            () {},
          ),
          _action(
            Icons.auto_awesome_rounded,
            '',
            'Vibe',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _action(
    IconData icon,
    String count,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: text, size: 25),
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
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFF5B5B66),
          size: 38,
        ),
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
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
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
          border: Border(
            top: BorderSide(color: Color(0xFF202026)),
          ),
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
                  child: const Icon(
                    Icons.add_rounded,
                    color: text,
                    size: 34,
                  ),
                ),
              ),
            ),
            _navItem(Icons.chat_bubble_outline_rounded, 'Chat', false),
            _navItem(Icons.person_outline_rounded, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? purple : text,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected ? purple : text,
              fontSize: 10,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showTuneSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111116),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tune your feed',
                  style: TextStyle(
                    color: text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose what you want to see more of.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                _tuneOption(
                  'For You',
                  'Personalized recommendations',
                  Icons.auto_awesome_rounded,
                ),
                _tuneOption(
                  'Fresh',
                  'Show newer posts first',
                  Icons.fiber_new_rounded,
                ),
                _tuneOption(
                  'Following',
                  'Prioritize creators you follow',
                  Icons.people_outline_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tuneOption(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: purple, size: 19),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: muted, fontSize: 11),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}
