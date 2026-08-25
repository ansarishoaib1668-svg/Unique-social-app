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

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .limit(100)
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open chat. Please try again.'),
        ),
      );
    }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chat',
          style: TextStyle(
            color: text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
              color: text,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add_rounded,
              color: purple,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(
            height: 1,
            color: border,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _usersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load users',
                      style: TextStyle(color: muted),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: purple),
                  );
                }

                final currentUid = _currentUser?.uid;
                final query = _searchQuery;

                final users = snapshot.data?.docs.where((doc) {
                  if (doc.id == currentUid) return false;

                  if (query.isEmpty) return true;

                  final data = doc.data();
                  final name =
                      (data['name'] ?? '').toString().toLowerCase();
                  final username =
                      (data['username'] ?? '').toString().toLowerCase();

                  return name.contains(query) ||
                      username.contains(query);
                }).toList() ?? [];

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No other users found',
                      style: TextStyle(color: muted),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 84,
                    color: border,
                  ),
                  itemBuilder: (context, index) {
                    final data = users[index].data();
                    final name = (data['name'] ?? 'Viewsta User').toString();
                    final username =
                        (data['username'] ?? '').toString();
                    final photoUrl =
                        (data['photoUrl'] ?? '').toString();

                    return ListTile(
                      onTap: () => _openChat(
                        users[index].id,
                        data,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFEDE9FE),
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl.isEmpty
                            ? Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : 'V',
                                style: const TextStyle(
                                  color: purple,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          color: text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        username.isEmpty ? '' : '@$username',
                        style: const TextStyle(color: muted),
                      ),
                      trailing: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: purple,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
