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
  static const text = Color(0xFF17171D);
  static const muted = Color(0xFF77737E);

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
                  SliverToBoxAdapter(child: _streamTabs()),
                  SliverToBoxAdapter(child: _moodRow()),
                  SliverToBoxAdapter(child: const SizedBox(height: 12)),
                  StreamBuilder<List<PostModel>>(
                    stream: _firestoreService.getPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: _message(
                            Icons.cloud_off_rounded,
                            'Unable to load your Viewstream right now.',
                          ),
                        );
                      }

                      final posts = snapshot.data ?? <PostModel>[];

                      if (posts.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _message(
                            Icons.photo_library_outlined,
                            'No posts yet. Your Viewstream will appear here.',
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                              child: _postCard(posts[index]),
                            );
                          },
                          childCount: posts.length,
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
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
      padding: const EdgeInsets.fromLTRB(22, 10, 18, 8),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'view',
                  style: TextStyle(
                    color: text,
                    fontSize: 31,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'sta',
                  style: TextStyle(
                    color: purple,
                    fontSize: 31,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _headerIcon(Icons.bolt_rounded),
          const SizedBox(width: 18),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _headerIcon(Icons.notifications_none_rounded),
              Positioned(
                right: 1,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          _headerIcon(Icons.search_rounded),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Icon(icon, color: text, size: 30);
  }

  Widget _streamTabs() {
    const tabs = ['For You', 'Following', 'Fresh'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 16, 10),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 26),
              child: GestureDetector(
                onTap: () => setState(() => _streamTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _streamTab == i ? purple : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: _streamTab == i ? Colors.white : text,
                      fontSize: 16,
                      fontWeight: _streamTab == i
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: purple, width: 1.5),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: purple,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodRow() {
    const moods = [
      ('🔥', 'Chill'),
      ('📈', 'Trending'),
      ('🎨', 'Creative'),
      ('🌎', 'Explore'),
      ('😀', 'Fun'),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: moods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final mood = moods[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E5E9)),
            ),
            child: Row(
              children: [
                Text(mood.$1, style: const TextStyle(fontSize: 17)),
                const SizedBox(width: 7),
                Text(
                  mood.$2,
                  style: const TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _postCard(PostModel post) {
    final hasImage = post.imageUrl.trim().isNotEmpty;
    final comments = post.comments.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE3E3E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _postHeader(),
          if (hasImage)
            AspectRatio(
              aspectRatio: 0.8,
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
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
            )
          else
            _mediaFallback(),
          _actions(post),
          if (post.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
              child: Text(
                post.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: text,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Text(
              comments == 0 ? 'View comments' : 'View all $comments comments',
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 15),
            child: Text(
              'Just now',
              style: TextStyle(color: muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _postHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 14, 14, 13),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: purple, width: 1.8),
            ),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFF1ECFF),
              child: Icon(
                Icons.person_outline_rounded,
                color: purple,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'View Creator',
                      style: TextStyle(
                        color: text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF1689F5),
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  '5 days ago',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: text, size: 25),
        ],
      ),
    );
  }

  Widget _actions(PostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
      child: Row(
        children: [
          _action(
            Icons.favorite_border_rounded,
            '${post.likes}',
            'Glow',
            const Color(0xFFFF405D),
            () => _firestoreService.likePost(post.id),
          ),
          _action(
            Icons.chat_bubble_outline_rounded,
            '${post.comments.length}',
            'Voice',
            const Color(0xFF8B5CF6),
            () {},
          ),
          _action(
            Icons.graphic_eq_rounded,
            '0',
            'Pass',
            const Color(0xFF38A8FF),
            () {},
          ),
          _action(
            Icons.bookmark_border_rounded,
            '0',
            'Vault',
            const Color(0xFF8AD51B),
            () {},
          ),
          _action(
            Icons.auto_awesome_rounded,
            '',
            'Vibe',
            const Color(0xFF9B5CFF),
            () {},
          ),
          const Spacer(),
          const Icon(
            Icons.bookmark_border_rounded,
            color: text,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _action(
    IconData icon,
    String count,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 27),
                  if (count.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      count,
                      style: const TextStyle(
                        color: text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
      height: 300,
      color: const Color(0xFFF7F7FA),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: purple,
          size: 42,
        ),
      ),
    );
  }

  Widget _message(IconData icon, String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE7E7EB)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: purple, size: 30),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 82,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE8E8EC)),
          ),
        ),
        child: Row(
          children: [
            _navItem(Icons.home_filled, 'Home', true),
            _navItem(Icons.explore_outlined, 'Explore', false),
            Expanded(
              child: Center(
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: purple,
                    boxShadow: [
                      BoxShadow(
                        color: purple.withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 38,
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
            size: 26,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected ? purple : text,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
