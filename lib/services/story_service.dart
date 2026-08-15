import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> createStory({
    required String mediaUrl,
    required String mediaType,
    String mood = 'Chill',
    bool live = false,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('LOGIN_REQUIRED');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

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
      'mood': mood,
      'live': live,
      'createdAt': now,
      'expiresAt': expiresAt,
      'viewedBy': <String>[],
      'likedBy': <String>[],
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> myActiveStories() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('stories')
        .where('userId', isEqualTo: user.uid)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> activeStories() {
    return _firestore
        .collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .snapshots();
  }

  static Future<void> markViewed(String storyId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('stories').doc(storyId).update({
      'viewedBy': FieldValue.arrayUnion([user.uid]),
    });
  }

  static Future<void> toggleLike(String storyId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('LOGIN_REQUIRED');
    }

    final ref = _firestore.collection('stories').doc(storyId);

    final snapshot = await ref.get();
    final data = snapshot.data() ?? {};

    final likedBy = List<String>.from(data['likedBy'] ?? <String>[]);

    if (likedBy.contains(user.uid)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> story(String storyId) {
    return _firestore.collection('stories').doc(storyId).snapshots();
  }

  static Future<List<Map<String, dynamic>>> viewerProfiles(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return [];

    final results = <Map<String, dynamic>>[];

    for (final userId in userIds) {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        results.add({'id': userId, ...?doc.data()});
      }
    }

    return results;
  }

  static Future<void> sendReply({
    required String storyId,
    required String message,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('LOGIN_REQUIRED');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    final userData = userDoc.data() ?? {};

    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('replies')
        .add({
          'userId': user.uid,
          'username': userData['username'] ?? user.displayName ?? 'User',
          'photoUrl': userData['photoUrl'],
          'message': message,
          'createdAt': Timestamp.now(),
        });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> replies(String storyId) {
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots();
  }
}
