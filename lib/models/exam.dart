class Exam {
  final String id;
  final String name;
  final String image;
  final String description;

  Exam({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
    );
  }
} 