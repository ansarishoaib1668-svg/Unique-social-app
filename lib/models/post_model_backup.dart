class PostModel {
  final String id;
  final String text;
  final int likes;

  PostModel({
    required this.id,
    required this.text,
    required this.likes,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      text: map['text'] ?? '',
      likes: map['likes'] ?? 0,
    );
  }
}
