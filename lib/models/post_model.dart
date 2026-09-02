import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String text;
  final int likes;
  final String imageUrl;
  final String videoUrl;
  final String type;
  final List<String> comments;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.likes,
    required this.imageUrl,
    required this.videoUrl,
    required this.type,
    required this.comments,
    required this.createdAt,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    final rawComments = map['comments'];

    final List<String> parsedComments = [];

    if (rawComments is List) {
      for (final comment in rawComments) {
        if (comment is String) {
          parsedComments.add(comment);
        } else if (comment is Map) {
          final text = comment['text'];
          if (text is String && text.isNotEmpty) {
            parsedComments.add(text);
          }
        }
      }
    }

    return PostModel(
      id: id,
      userId: map['userId'] is String ? map['userId'] : '',
      text: map['text'] is String ? map['text'] : '',
      likes: map['likes'] is int ? map['likes'] : 0,
      imageUrl: map['imageUrl'] is String ? map['imageUrl'] : '',
      videoUrl: map['videoUrl'] is String ? map['videoUrl'] : '',
      comments: parsedComments,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      type: map['type'] is String ? map['type'] as String : 'photo',
    );
  }
}
