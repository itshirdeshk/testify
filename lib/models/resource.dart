class Resource {
  final String id;
  final String title;
  final String description;
  final String url;
  final String type;
  final String size;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.type,
    required this.size,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      type: json['typeOfFile'],
      size: json['size'],
    );
  }
}
