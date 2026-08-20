import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _purple = Color(0xFF7C3AED);
  static const _blue = Color(0xFF38BDF8);
  static const _background = Color(0xFF0F0F12);
  static const _card = Color(0xFF1A1A22);
  static const _muted = Color(0xFFA1A1AA);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Text(
            'Please sign in again.',
            style: TextStyle(color: Colors.white),
          ),
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
                SliverToBoxAdapter(
                  child: _profileHeader(user, name, username, photoUrl),
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
                  sliver: _postGrid(),
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

  Widget _profileHeader(
    User? user,
    String name,
    String username,
    String? photoUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
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
                color: _background,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: _card,
                backgroundImage:
                    photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white70,
                        size: 42,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _verifiedBadge(user),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _verifiedBadge(User? user) {
    // Verification will be connected to Firestore later.
    // Do not show a badge for normal users.
    return const SizedBox.shrink();
  }

  Widget _stats(int postsCount, int followersCount, int followingCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: const [
          Expanded(
            child: _Stat(value: '0', label: 'Posts'),
          ),
          Expanded(
            child: _Stat(value: '0', label: 'Supporters'),
          ),
          Expanded(
            child: _Stat(value: '0', label: 'Supporting'),
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
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      joinedText =
          '${joinedAt.day.toString().padLeft(2, '0')} '
          '${months[joinedAt.month - 1]} '
          '${joinedAt.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bio,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          if (location != null) ...[
            const SizedBox(height: 8),
            _profileInfoRow(
              Icons.location_on_outlined,
              location,
            ),
          ],

          if (interests != null) ...[
            const SizedBox(height: 7),
            _profileInfoRow(
              Icons.auto_awesome_outlined,
              interests,
            ),
          ],

          if (website != null) ...[
            const SizedBox(height: 7),
            _profileInfoRow(
              Icons.link_rounded,
              website,
              purple: true,
            ),
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

  Widget _profileInfoRow(
    IconData icon,
    String value, {
    bool purple = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: purple ? _purple : _muted,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: purple ? const Color(0xFFB9A0FF) : _muted,
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _ProfileButton(
              label: 'Edit Profile',
              filled: true,
              onTap: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );

                if (updated == true) {
                  // Profile data is reloaded when the screen rebuilds.
                }
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
      height: 112,
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
              color: _card,
              border: Border.all(color: const Color(0xFF35353D)),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 7),
          const Text(
            'New',
            style: TextStyle(color: Colors.white70, fontSize: 12),
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
          top: BorderSide(color: Color(0xFF24242A)),
          bottom: BorderSide(color: Color(0xFF24242A)),
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

  Widget _postGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          color: _card,
          child: const Icon(
            Icons.image_outlined,
            color: Color(0xFF55555F),
            size: 30,
          ),
        );
      }, childCount: 9),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
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
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? const Color(0xFF7C3AED) : null,
          side: BorderSide(
            color: filled ? const Color(0xFF7C3AED) : const Color(0xFF35353D),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: filled ? FontWeight.w700 : FontWeight.w600,
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
      height: 48,
      child: Center(
        child: Icon(
          icon,
          color: active ? Colors.white : const Color(0xFF777781),
          size: 22,
        ),
      ),
    );
  }
}
