class Test {
  final String id;
  final String title;
  final int totalQuestions;
  final int duration;
  final int totalMarks;
  final bool isFree;
  final String mockTest;

  Test({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.duration,
    required this.totalMarks,
    required this.isFree,
    required this.mockTest,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['_id'],
      title: json['title'],
      totalQuestions: json['totalQuestions'],
      duration: json['duration'],
      totalMarks: json['totalMarks'],
      isFree: json['isFree'],
      mockTest: json['mockTest'],
    );
  }
}

class TestResponse {
  List<Test>? unattemptedTests;
  List<Test>? attemptedTests;

  TestResponse({
    required this.unattemptedTests,
    required this.attemptedTests,
  });

  factory TestResponse.fromJson(Map<String, dynamic> json) {
    return TestResponse(
      unattemptedTests:
          json['unattemptedTests'].map((test) => Test.fromJson(test)).toList(),
      attemptedTests: json['attemptedTests']
          .map((test) => Test.fromJson(test['test']))
          .toList(),
    );
  }
}
