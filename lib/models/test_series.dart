class TestSeries {
  final String id;
  final String name;
  final String image;
  final int totalTests;
  final int freeTests;
  final String subExam;

  TestSeries({
    required this.id,
    required this.name,
    required this.image,
    required this.totalTests,
    required this.freeTests,
    required this.subExam,
  });

  factory TestSeries.fromJson(Map<String, dynamic> json) {
    return TestSeries(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      totalTests: json['totalTests'],
      freeTests: json['freeTests'],
      subExam: json['subExam'],
    );
  }
}
