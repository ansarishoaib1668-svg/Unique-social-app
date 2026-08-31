import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import 'edit_profile_screen.dart';
import '../create/create_hub_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _purple = Color(0xFF7C3AED);
  static const _blue = Color(0xFF38BDF8);
  static const _background = Colors.white;
  static const _text = Color(0xFF18181B);
  static const _muted = Color(0xFF71717A);
  static const _border = Color(0xFFE4E4E7);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Text('Please sign in again.', style: TextStyle(color: _text)),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};

        final name =
            _readString(data['displayName']) ??
            _readString(data['name']) ??
            user.displayName?.trim() ??
            'Your Name';

        final username =
            _readString(data['username']) ??
            user.email?.split('@').first.trim() ??
            'username';

        final bio = _readString(data['bio']) ?? 'Your bio goes here.';
        final location = _readString(data['location']);
        final interests = _readString(data['interests']);
        final website = _readString(data['website']);

        final joinedAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : user.metadata.creationTime;

        final photoUrl =
            _readString(data['photoUrl']) ??
            (user.photoURL?.trim().isNotEmpty == true
                ? user.photoURL!.trim()
                : null);

        final postsCount = _readInt(data['postsCount']);
        final followersCount = _readInt(data['followersCount']);
        final followingCount = _readInt(data['followingCount']);

        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _topBar(context)),
                SliverToBoxAdapter(
                  child: _profileHeader(name, username, photoUrl),
                ),
                SliverToBoxAdapter(
                  child: _stats(postsCount, followersCount, followingCount),
                ),
                SliverToBoxAdapter(
                  child: _profileInfo(
                    bio,
                    location,
                    interests,
                    website,
                    joinedAt,
                  ),
                ),
                SliverToBoxAdapter(child: _actions(context)),
                SliverToBoxAdapter(child: _highlights()),
                SliverToBoxAdapter(child: _tabs()),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 2,
                    right: 2,
                    bottom: 100,
                  ),
                  sliver: _postGrid(user.uid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String? _readString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _text,
              size: 21,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_rounded, color: _text, size: 21),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, color: _text, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(String name, String username, String? photoUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [_purple, _blue]),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFF4F4F5),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? const Icon(
                        Icons.person_outline_rounded,
                        color: _muted,
                        size: 42,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Newbie',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats(int postsCount, int followersCount, int followingCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: _Stat(value: postsCount.toString(), label: 'Posts'),
          ),
          Expanded(
            child: _Stat(value: followersCount.toString(), label: 'Supporters'),
          ),
          Expanded(
            child: _Stat(value: followingCount.toString(), label: 'Supporting'),
          ),
        ],
      ),
    );
  }

  Widget _profileInfo(
    String bio,
    String? location,
    String? interests,
    String? website,
    DateTime? joinedAt,
  ) {
    String? joinedText;

    if (joinedAt != null) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      joinedText =
          '${joinedAt.day.toString().padLeft(2, '0')} '
          '${months[joinedAt.month - 1]} '
          '${joinedAt.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bio,
            style: const TextStyle(
              color: _text,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (location != null) ...[
            const SizedBox(height: 8),
            _profileInfoRow(Icons.location_on_outlined, location),
          ],
          if (interests != null) ...[
            const SizedBox(height: 7),
            _profileInfoRow(Icons.auto_awesome_outlined, interests),
          ],
          if (website != null) ...[
            const SizedBox(height: 7),
            _profileInfoRow(Icons.link_rounded, website, purple: true),
          ],
          if (joinedText != null) ...[
            const SizedBox(height: 8),
            _profileInfoRow(
              Icons.calendar_today_outlined,
              'Joined Viewsta $joinedText',
            ),
          ],
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String value, {bool purple = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: purple ? _purple : _muted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: purple ? _purple : _muted,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _ProfileButton(
              label: 'Edit Profile',
              filled: true,
              onTap: () async {
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ProfileButton(
              label: 'Share Profile',
              filled: false,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlights() {
    return SizedBox(
      height: 108,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [_addHighlight()],
      ),
    );
  }

  Widget _addHighlight() {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _purple, width: 1.5),
            ),
            child: const Icon(Icons.add_rounded, color: _purple, size: 30),
          ),
          const SizedBox(height: 7),
          const Text(
            'New',
            style: TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _border),
          bottom: BorderSide(color: _border),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _ProfileTab(icon: Icons.grid_on_rounded, active: true),
          ),
          Expanded(child: _ProfileTab(icon: Icons.movie_outlined)),
          Expanded(child: _ProfileTab(icon: Icons.auto_stories_outlined)),
          Expanded(child: _ProfileTab(icon: Icons.bookmark_border_rounded)),
          Expanded(child: _ProfileTab(icon: Icons.person_pin_outlined)),
        ],
      ),
    );
  }

  Widget _postGrid(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator(color: _purple)),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'Unable to load posts.',
                  style: TextStyle(color: _muted),
                ),
              ),
            ),
          );
        }

        final posts =
            snapshot.data?.docs
                .map((doc) => PostModel.fromMap(doc.id, doc.data()))
                .where((post) => post.userId == uid)
                .toList() ??
            [];

        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 46,
                      color: Color(0xFFD4D4D8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No posts yet',
                      style: TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Share your first view with the world.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                    SizedBox(height: 16),
                    _CreatePostButton(),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = posts[index];

            if (post.imageUrl.isNotEmpty) {
              return Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF4F4F5),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: _muted,
                      size: 30,
                    ),
                  );
                },
              );
            }

            return Container(
              color: const Color(0xFFF4F4F5),
              child: const Icon(Icons.movie_outlined, color: _muted, size: 30),
            );
          }, childCount: posts.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF18181B),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF71717A), fontSize: 12),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? const Color(0xFF7C3AED) : Colors.white,
          side: BorderSide(
            color: filled ? const Color(0xFF7C3AED) : const Color(0xFFD4D4D8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFF18181B),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _ProfileTab({required this.icon, this.active = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Icon(
          icon,
          color: active ? const Color(0xFF7C3AED) : const Color(0xFFA1A1AA),
          size: 22,
        ),
      ),
    );
  }
}

class _CreatePostButton extends StatelessWidget {
  const _CreatePostButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateHubScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        '+ Create Post',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
