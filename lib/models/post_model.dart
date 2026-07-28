class PostModel {
  final String id;
  final String text;
  final int likes;
  final String imageUrl;
  final String videoUrl;
  final List<String> comments;

  PostModel({
    required this.id,
    required this.text,
    required this.likes,
    required this.imageUrl,
    required this.videoUrl,
    required this.comments,
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
      text: map['text'] is String ? map['text'] : '',
      likes: map['likes'] is int ? map['likes'] : 0,
      imageUrl: map['imageUrl'] is String ? map['imageUrl'] : '',
      videoUrl: map['videoUrl'] is String ? map['videoUrl'] : '',
      comments: parsedComments,
    );
  }
}
