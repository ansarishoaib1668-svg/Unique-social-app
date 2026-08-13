import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_model.dart';

class PostActionState {
  final bool glowed;
  final bool vaulted;
  final String? vibe;
  final int passCount;

  const PostActionState({
    required this.glowed,
    required this.vaulted,
    required this.vibe,
    required this.passCount,
  });
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<PostModel>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// Returns the current user's persistent state for all five post actions.
  Future<PostActionState> getPostActionState(String postId, String uid) async {
    final postRef = _db.collection('posts').doc(postId);
    final actionRef = postRef.collection('actions').doc(uid);
    final vaultRef = _db.collection('users').doc(uid).collection('vault').doc(postId);

    final results = await Future.wait([
      actionRef.get(),
      vaultRef.get(),
      postRef.get(),
    ]);

    final action = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final vault = results[1] as DocumentSnapshot<Map<String, dynamic>>;
    final post = results[2] as DocumentSnapshot<Map<String, dynamic>>;

    final actionData = action.data();
    final postData = post.data();

    return PostActionState(
      glowed: actionData?['glow'] == true,
      vaulted: vault.exists,
      vibe: actionData?['vibe'] is String ? actionData!['vibe'] as String : null,
      passCount: postData?['passes'] is int ? postData!['passes'] as int : 0,
    );
  }

  /// Glow is a true per-user toggle. It cannot be double-counted.
  Future<void> setGlow(String postId, String uid, bool enabled) async {
    final postRef = _db.collection('posts').doc(postId);
    final actionRef = postRef.collection('actions').doc(uid);

    await _db.runTransaction((transaction) async {
      final actionSnap = await transaction.get(actionRef);
      final current = actionSnap.data()?['glow'] == true;

      if (current == enabled) return;

      if (enabled) {
        transaction.set(actionRef, {
          'uid': uid,
          'glow': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        transaction.update(postRef, {
          'likes': FieldValue.increment(1),
        });
      } else {
        transaction.set(actionRef, {
          'uid': uid,
          'glow': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        transaction.update(postRef, {
          'likes': FieldValue.increment(-1),
        });
      }
    });
  }

  Future<void> addVoiceComment(
    String postId,
    String uid,
    String displayName,
    String comment,
  ) async {
    final clean = comment.trim();
    if (clean.isEmpty) return;

    await _db.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([
        {
          'uid': uid,
          'displayName': displayName,
          'text': clean,
          'createdAt': Timestamp.now(),
        },
      ]),
    });
  }

  /// Pass uses the native Android share sheet and records one pass per user.
  Future<void> recordPass(String postId, String uid) async {
    final postRef = _db.collection('posts').doc(postId);
    final passRef = postRef.collection('passes').doc(uid);

    await _db.runTransaction((transaction) async {
      final passSnap = await transaction.get(passRef);
      if (passSnap.exists) return;

      transaction.set(passRef, {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(postRef, {
        'passes': FieldValue.increment(1),
      }, SetOptions(merge: true));
    });
  }

  Future<void> setVault(String postId, String uid, bool enabled) async {
    final vaultRef = _db.collection('users').doc(uid).collection('vault').doc(postId);
    final postRef = _db.collection('posts').doc(postId);

    if (enabled) {
      final postSnap = await postRef.get();
      final data = postSnap.data() ?? <String, dynamic>{};
      await vaultRef.set({
        'postId': postId,
        'uid': uid,
        'text': data['text'] ?? '',
        'imageUrl': data['imageUrl'] ?? '',
        'videoUrl': data['videoUrl'] ?? '',
        'savedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await vaultRef.delete();
    }
  }

  Future<void> setVibe(String postId, String uid, String vibe) async {
    await _db.collection('posts').doc(postId).collection('actions').doc(uid).set({
      'uid': uid,
      'vibe': vibe,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Kept for compatibility with existing screens.
  Future<void> likePost(String postId) async {
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> addComment(String postId, String comment) async {
    await _db.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }

  Future<void> createPost({
    required String text,
    String? imageUrl,
    String? videoUrl,
  }) async {
    await _db.collection('posts').add({
      'text': text,
      'imageUrl': imageUrl ?? '',
      'videoUrl': videoUrl ?? '',
      'likes': 0,
      'passes': 0,
      'comments': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
