class SubExam {
  final String id;
  final String name;
  final String examId;
  final String description;
  final String? image;

  SubExam({
    required this.id,
    required this.name,
    required this.examId,
    required this.description,
    this.image,
  });

  factory SubExam.fromJson(Map<String, dynamic> json) {
    return SubExam(
      id: json['_id'],
      name: json['name'],
      examId: json['exam'],
      description: json['description'],
      image: json['image'],
    );
  }
} 