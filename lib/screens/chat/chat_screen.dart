import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const purple = Color(0xFF7C3AED);
  static const text = Color(0xFF111114);
  static const muted = Color(0xFF777781);
  static const border = Color(0xFFE8E8EE);

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _pulsePresets = [
    {'icon': '😊', 'title': 'Free'},
    {'icon': '🎧', 'title': 'Listening'},
    {'icon': '🎮', 'title': 'Gaming'},
    {'icon': '📚', 'title': 'Studying'},
    {'icon': '🔥', 'title': 'Creating'},
    {'icon': '💬', 'title': 'Talk'},
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .limit(100)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _chatsStream() {
    final uid = _currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots();
  }

  String _chatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _openChat(
    String otherUid,
    Map<String, dynamic> otherUser,
  ) async {
    final me = _currentUser?.uid;
    if (me == null || otherUid.isEmpty || me == otherUid) return;

    final chatId = _chatId(me, otherUid);
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

    try {
      await chatRef.set({
        'participants': [me, otherUid],
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(
            chatId: chatId,
            otherUid: otherUid,
            otherUser: otherUser,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open chat. Please try again.'),
        ),
      );
    }
  }

  Future<void> _setPulse({
    required String type,
    required String icon,
    String customText = '',
  }) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    final now = Timestamp.now();
    final expiresAt = Timestamp.fromDate(
      now.toDate().add(const Duration(hours: 24)),
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'pulse': {
          'type': type,
          'icon': icon,
          'text': customText.trim(),
          'createdAt': now,
          'expiresAt': expiresAt,
        },
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$icon $type Pulse is live for 24 hours ✨',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not set Pulse. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _receivedPulseVibes() {
    final uid = _currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('pulse_reactions')
        .where('receiverId', isEqualTo: uid)
        .where('type', isEqualTo: 'vibe')
        .snapshots();
  }


  Future<void> _removePulse() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'pulse': FieldValue.delete(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Pulse was removed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove Pulse.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPulsePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "What's your vibe?",
                  style: TextStyle(
                    color: text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share what you are up to right now.',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: _pulsePresets.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (_, index) {
                    final item = _pulsePresets[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        Navigator.pop(context);

                        await _setPulse(
                          type: item['title'].toString(),
                          icon: item['icon'].toString(),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F5FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE9E2FF),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['icon'],
                              style: const TextStyle(fontSize: 25),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item['title'],
                              style: const TextStyle(
                                color: text,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCustomPulse();
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Custom Pulse'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: purple,
                    side: const BorderSide(color: purple),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  void _showCustomPulse() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create your Pulse'),
          content: TextField(
            controller: controller,
            maxLength: 60,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Aaj kaafi free hoon 😄',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: purple,
              ),
              onPressed: () async {
                final value = controller.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(dialogContext);

                await _setPulse(
                  type: 'Custom',
                  icon: '✍️',
                  customText: value,
                );
              },
              child: const Text('Set Pulse'),
            ),
          ],
        );
      },
    );
  }

  Widget _avatar(
    String name,
    String photoUrl, {
    double radius = 28,
    bool active = false,
    bool pulse = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(pulse ? 3 : 0),
          decoration: pulse
              ? const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFF38BDF8),
                    ],
                  ),
                )
              : null,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFEDE9FE),
            backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'V',
                    style: const TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
        ),
        if (active)
          Positioned(
            right: -1,
            bottom: 1,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _sendSayHi(String receiverUid) async {
    final senderUid = _currentUser?.uid;

    if (senderUid == null ||
        receiverUid.isEmpty ||
        senderUid == receiverUid) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('pulse_reactions')
          .doc('${senderUid}_${receiverUid}_say_hi')
          .set({
        'senderId': senderUid,
        'receiverId': receiverUid,
        'type': 'say_hi',
        'createdAt': FieldValue.serverTimestamp(),
        'seen': false,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('👋 Say Hi sent'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send Say Hi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _markPulseVibesSeen(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> vibes,
  ) async {
    if (vibes.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    var hasChanges = false;

    for (final doc in vibes) {
      final data = doc.data();

      if (data['seen'] != true) {
        batch.update(doc.reference, {
          'seen': true,
        });
        hasChanges = true;
      }
    }

    if (!hasChanges) return;

    try {
      await batch.commit();
    } catch (_) {}
  }

  void _showReceivedPulseVibes(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> vibes,
  ) {
    _markPulseVibesSeen(vibes);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '💜 Pulse Vibes',
                      style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${vibes.length} ${vibes.length == 1 ? 'person has' : 'people have'} vibed with your Pulse',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ...vibes.take(5).map((doc) {
                  final data = doc.data();
                  final senderId =
                      (data['senderId'] ?? '').toString();

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF0E8FF),
                      child: Text('💜'),
                    ),
                    title: const Text(
                      'Someone vibed with your Pulse',
                      style: TextStyle(
                        color: text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Send them a message',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: senderId.isEmpty
                          ? null
                          : () async {
                              Navigator.pop(sheetContext);

                              final userDoc = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(senderId)
                                  .get();

                              if (!userDoc.exists || !mounted) return;

                              await _openChat(
                                senderId,
                                userDoc.data() ?? {},
                              );
                            },
                      child: const Text(
                        'Message',
                        style: TextStyle(
                          color: purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _pulseCard({
    required String name,
    required String photoUrl,
    required String icon,
    required String status,
    required String detail,
    required String receiverUid,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _avatar(
                  name,
                  photoUrl,
                  radius: 20,
                  active: true,
                  pulse: true,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              '$icon $status',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _sendSayHi(receiverUid),
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '👋 Say Hi',
                        style: TextStyle(
                          color: purple,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? purple : const Color(0xFFF5F4F8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showPulsePicker,
        backgroundColor: purple,
        elevation: 5,
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Viewsta✨',
                      style: TextStyle(
                        color: text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: text,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search people, chats & media',
                  hintStyle: const TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: muted,
                    size: 21,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF6F6F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Text(
                    'VIEW PULSE',
                    style: TextStyle(
                      color: text,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const Spacer(),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _receivedPulseVibes(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (count > 0) ...[
                            GestureDetector(
                              onTap: () {
                                _showReceivedPulseVibes(
                                  snapshot.data?.docs ?? [],
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F0FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '💜',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: purple,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ],

                          GestureDetector(
                            onTap: _showPulsePicker,
                            child: const Text(
                              '+ Your Pulse',
                              style: TextStyle(
                                color: purple,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Your Pulse
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final pulse = data?['pulse'];

                var hasPulse = false;
                String icon = '✨';
                String type = 'Set your vibe';
                String pulseText = 'Tell friends what is happening right now.';
                String remaining = '';

                if (pulse is Map) {
                  final expiresAt = pulse['expiresAt'];

                  if (expiresAt is Timestamp &&
                      expiresAt.toDate().isAfter(DateTime.now())) {
                    hasPulse = true;

                    icon = (pulse['icon'] ?? '✨').toString();
                    type = (pulse['type'] ?? 'Pulse').toString();

                    final savedText =
                        (pulse['text'] ?? '').toString().trim();

                    pulseText = savedText.isNotEmpty
                        ? savedText
                        : 'Available now';

                    final difference =
                        expiresAt.toDate().difference(DateTime.now());

                    final hours = difference.inHours;
                    final minutes = difference.inMinutes % 60;

                    remaining = hours > 0
                        ? '${hours}h left'
                        : '${minutes.clamp(1, 59)}m left';
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF8F5FF),
                          Color(0xFFF7FBFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE8E0FF),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: hasPulse
                                  ? purple
                                  : const Color(0xFFE3E0EA),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            hasPulse ? icon : '＋',
                            style: TextStyle(
                              fontSize: hasPulse ? 23 : 22,
                              color: hasPulse ? null : purple,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    hasPulse
                                        ? 'Your Pulse'
                                        : 'Your Pulse',
                                    style: const TextStyle(
                                      color: text,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (hasPulse &&
                                      remaining.isNotEmpty) ...[
                                    const SizedBox(width: 7),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDE9FE),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        remaining,
                                        style: const TextStyle(
                                          color: purple,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasPulse
                                    ? '$type • $pulseText'
                                    : pulseText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hasPulse)
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              color: muted,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showPulsePicker();
                              } else if (value == 'remove') {
                                _removePulse();
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit Pulse'),
                              ),
                              PopupMenuItem(
                                value: 'remove',
                                child: Text('Remove Pulse'),
                              ),
                            ],
                          )
                        else
                          IconButton(
                            onPressed: _showPulsePicker,
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: purple,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'FRIENDS PULSE',
                  style: TextStyle(
                    color: text,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 7),

            SizedBox(
              height: 190,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _usersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: purple,
                        ),
                      ),
                    );
                  }

                  final currentUid = _currentUser?.uid;

                  final users = snapshot.data?.docs.where((doc) {
                    return doc.id != currentUid;
                  }).toList() ?? [];

                  final now = DateTime.now();

                  final pulseUsers = users.where((doc) {
                    final data = doc.data();
                    final pulse = data['pulse'];

                    if (pulse is! Map) return false;

                    final expiresAt = pulse['expiresAt'];

                    return expiresAt is Timestamp &&
                        expiresAt.toDate().isAfter(now);
                  }).toList();

                  if (pulseUsers.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'No active Pulses yet.\nSet yours and start the vibe ✨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 8,
                    ),
                    itemCount: pulseUsers.length,
                    itemBuilder: (context, index) {
                      final doc = pulseUsers[index];
                      final data = doc.data();

                      final name =
                          (data['name'] ?? 'Viewsta User').toString();

                      final photoUrl =
                          (data['photoUrl'] ?? '').toString();

                      final pulse =
                          data['pulse'] as Map<dynamic, dynamic>;

                      final icon =
                          (pulse['icon'] ?? '✨').toString();

                      final type =
                          (pulse['type'] ?? 'Pulse').toString();

                      final pulseText =
                          (pulse['text'] ?? '').toString().trim();

                      final detail = pulseText.isNotEmpty
                          ? pulseText
                          : 'Available now';

                      return _pulseCard(
                        name: name,
                        photoUrl: photoUrl,
                        icon: icon,
                        status: type,
                        detail: detail,
                        receiverUid: doc.id,
                        onTap: () => _openChat(doc.id, data),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  _tab('Messages', 0),
                  const SizedBox(width: 7),
                  _tab('Active Now', 1),
                  const SizedBox(width: 7),
                  _tab('New Views', 2),
                  const SizedBox(width: 7),
                  _tab('Requests', 3),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _chatsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load chats',
                        style: TextStyle(color: muted),
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: purple,
                      ),
                    );
                  }

                  final currentUid = _currentUser?.uid;
                  if (currentUid == null) {
                    return const Center(
                      child: Text(
                        'Please log in again',
                        style: TextStyle(color: muted),
                      ),
                    );
                  }

                  final chats = snapshot.data?.docs ?? [];

                  if (chats.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'No conversations yet.\nStart a chat from Pulse ✨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
                    itemCount: chats.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final chatDoc = chats[index];
                      final chat = chatDoc.data();

                      final participants =
                          List<String>.from(
                        (chat['participants'] ?? const <String>[]),
                      );

                      final otherUid = participants.firstWhere(
                        (uid) => uid != currentUid,
                        orElse: () => '',
                      );

                      if (otherUid.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherUid)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          final userData =
                              userSnapshot.data?.data() ??
                                  <String, dynamic>{};

                          final name =
                              (userData['name'] ??
                                      'Viewsta User')
                                  .toString();

                          final username =
                              (userData['username'] ?? '')
                                  .toString();

                          final photoUrl =
                              (userData['photoUrl'] ?? '')
                                  .toString();

                          final isOnline =
                              userData['isOnline'] == true;

                          final lastMessage =
                              (chat['lastMessage'] ?? '')
                                  .toString()
                                  .trim();

                          final lastMessageSenderId =
                              (chat['lastMessageSenderId'] ?? '')
                                  .toString();

                          final sentByMe =
                              lastMessageSenderId == currentUid;

                          final timestamp =
                              chat['lastMessageAt'];

                          String timeText = '';

                          if (timestamp is Timestamp) {
                            final difference = DateTime.now()
                                .difference(timestamp.toDate());

                            if (difference.inMinutes < 1) {
                              timeText = 'Now';
                            } else if (difference.inMinutes < 60) {
                              timeText =
                                  '${difference.inMinutes}m';
                            } else if (difference.inHours < 24) {
                              timeText =
                                  '${difference.inHours}h';
                            } else if (difference.inDays < 7) {
                              timeText =
                                  '${difference.inDays}d';
                            } else {
                              final date =
                                  timestamp.toDate();

                              timeText =
                                  '${date.day}/${date.month}';
                            }
                          }

                          final preview = lastMessage.isEmpty
                              ? 'Start a conversation 👋'
                              : '${sentByMe ? 'You: ' : ''}$lastMessage';

                          final query = _searchQuery;

                          if (query.isNotEmpty &&
                              !name
                                  .toLowerCase()
                                  .contains(query) &&
                              !username
                                  .toLowerCase()
                                  .contains(query) &&
                              !lastMessage
                                  .toLowerCase()
                                  .contains(query)) {
                            return const SizedBox.shrink();
                          }

                          return InkWell(
                            borderRadius:
                                BorderRadius.circular(18),
                            onTap: () => _openChat(
                              otherUid,
                              userData,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 9,
                                horizontal: 2,
                              ),
                              child: Row(
                                children: [
                                  _avatar(
                                    name,
                                    photoUrl,
                                    radius: 28,
                                    active: isOnline,
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    const TextStyle(
                                                  color: text,
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight
                                                          .w800,
                                                ),
                                              ),
                                            ),
                                            if (timeText.isNotEmpty)
                                              Text(
                                                timeText,
                                                style:
                                                    const TextStyle(
                                                  color: muted,
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                username.isEmpty
                                                    ? preview
                                                    : '@$username  •  $preview',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    const TextStyle(
                                                  color: muted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.chatId,
    required this.otherUid,
    required this.otherUser,
  });

  final String chatId;
  final String otherUid;
  final Map<String, dynamic> otherUser;

  @override
  State<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _messageController = TextEditingController();

  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _markIncomingMessagesRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
  ) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || messages.isEmpty) return;

    final batch = _db.batch();
    var hasChanges = false;

    for (final doc in messages) {
      final data = doc.data();
      final senderId = (data['senderId'] ?? '').toString();

      if (senderId == me) continue;

      if (data['deliveredAt'] == null || data['seenAt'] == null) {
        batch.update(doc.reference, {
          if (data['deliveredAt'] == null)
            'deliveredAt': FieldValue.serverTimestamp(),
          if (data['seenAt'] == null)
            'seenAt': FieldValue.serverTimestamp(),
        });
        hasChanges = true;
      }
    }

    if (hasChanges) {
      try {
        await batch.commit();
      } catch (_) {}
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final me = FirebaseAuth.instance.currentUser?.uid;

    if (text.isEmpty || me == null) return;

    final messageRef = _db
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc();

    try {
      await messageRef.set({
        'senderId': me,
        'receiverId': widget.otherUid,
        'text': text,
        'sentAt': FieldValue.serverTimestamp(),
        'deliveredAt': null,
        'seenAt': null,
      });

      await _db.collection('chats').doc(widget.chatId).set({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': me,
      }, SetOptions(merge: true));

      _messageController.clear();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message could not be sent.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        (widget.otherUser['name'] ?? 'Viewsta User').toString();
    final username = (widget.otherUser['username'] ?? '').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage:
                  (widget.otherUser['photoUrl'] ?? '').toString().isNotEmpty
                      ? NetworkImage(
                          (widget.otherUser['photoUrl'] ?? '').toString(),
                        )
                      : null,
              child: (widget.otherUser['photoUrl'] ?? '').toString().isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF111114),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (username.isNotEmpty)
                  Text(
                    '@$username',
                    style: const TextStyle(
                      color: Color(0xFF777781),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('sentAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load messages',
                      style: TextStyle(
                        color: Color(0xFF777781),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C3AED),
                    ),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _markIncomingMessagesRead(messages);
                    }
                  });
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start a conversation 👋',
                      style: TextStyle(
                        color: Color(0xFF777781),
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                final me = FirebaseAuth.instance.currentUser?.uid;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();
                    final senderId = (data['senderId'] ?? '').toString();
                    final message = (data['text'] ?? '').toString();
                    final isMine = senderId == me;

                    final deliveredAt = data['deliveredAt'];
                    final seenAt = data['seenAt'];

                    final isDelivered = deliveredAt != null;
                    final isSeen = seenAt != null;

                    final sentTimestamp = data['sentAt'];
                    final sentDate = sentTimestamp is Timestamp
                        ? sentTimestamp.toDate()
                        : null;

                    final timeText = sentDate == null
                        ? ''
                        : MaterialLocalizations.of(context)
                            .formatTimeOfDay(
                            TimeOfDay.fromDateTime(sentDate),
                            alwaysUse24HourFormat: false,
                          );

                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 290,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMine
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFFF2F2F5),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(
                              isMine ? 18 : 4,
                            ),
                            bottomRight: Radius.circular(
                              isMine ? 4 : 18,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message,
                              style: TextStyle(
                                color: isMine
                                    ? Colors.white
                                    : const Color(0xFF111114),
                                fontSize: 15,
                              ),
                            ),
                            if (isMine && timeText.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSeen
                                        ? Icons.done_all_rounded
                                        : isDelivered
                                            ? Icons.done_all_rounded
                                            : Icons.done_rounded,
                                    size: 18,
                                    color: isSeen
                                        ? const Color(0xFF7C3AED)
                                        : const Color(0xFF777781),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    timeText,
                                    style: const TextStyle(
                                      color: Color(0xFF777781),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE8E8EE),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
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
}
