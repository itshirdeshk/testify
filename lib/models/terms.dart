class Terms {
  final String id;
  final String title;
  final String content;

  Terms({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
