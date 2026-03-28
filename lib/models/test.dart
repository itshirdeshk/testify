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
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      totalMarks: (json['totalMarks'] as num?)?.toInt() ?? 0,
      isFree: json['isFree'] == true,
      mockTest: (json['mockTest'] ?? '').toString(),
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
    final rawUnattempted = json['unattemptedTests'];
    final rawAttempted = json['attemptedTests'];
    final unattempted =
        rawUnattempted is List ? rawUnattempted : const <dynamic>[];
    final attempted = rawAttempted is List ? rawAttempted : const <dynamic>[];

    return TestResponse(
      unattemptedTests: unattempted
          .whereType<Map<String, dynamic>>()
          .map((test) => Test.fromJson(test))
          .toList(),
      attemptedTests: attempted
          .map((test) => test is Map<String, dynamic> ? test['test'] : null)
          .whereType<Map<String, dynamic>>()
          .map((test) => Test.fromJson(test))
          .toList(),
    );
  }
}
