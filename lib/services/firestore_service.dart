import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  Future<String> uploadFile(File file, String type) async {
    final ref = _storage
        .ref()
        .child('posts/${DateTime.now().millisecondsSinceEpoch}.$type');

    await ref.putFile(file);

    return await ref.getDownloadURL();
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
      'comments': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
