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
    return PostModel(
      id: id,
      text: map['text'] ?? '',
      likes: map['likes'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      comments: List<String>.from(map['comments'] ?? []),
    );
  }
}
