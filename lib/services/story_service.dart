import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static Future<void> createStory({
    required String mediaUrl,
    required String mediaType,
    bool live = false,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('LOGIN_REQUIRED');
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    final now = Timestamp.now();

    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(hours: 24)),
    );

    await _firestore.collection('stories').add({
      'userId': user.uid,
      'username': userData['username'] ?? user.displayName ?? 'User',
      'name': userData['name'] ?? user.displayName ?? 'User',
      'photoUrl': userData['photoUrl'],
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'live': live,
      'createdAt': now,
      'expiresAt': expiresAt,
      'viewedBy': <String>[],
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> activeStories() {
    return _firestore
        .collection('stories')
        .where(
          'expiresAt',
          isGreaterThan: Timestamp.now(),
        )
        .orderBy('expiresAt')
        .snapshots();
  }

  static Future<void> markViewed(String storyId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore
        .collection('stories')
        .doc(storyId)
        .update({
      'viewedBy': FieldValue.arrayUnion([user.uid]),
    });
  }
}
