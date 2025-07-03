class AboutUs {
  final String id;
  final String title;
  final String content;

  AboutUs({
    required this.id,
    required this.title,
    required this.content,
  });

  factory AboutUs.fromJson(Map<String, dynamic> json) {
    return AboutUs(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
