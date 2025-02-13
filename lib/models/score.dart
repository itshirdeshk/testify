class TestStats {
  final int totalParticipants;
  final num averageScore;
  final num bestScore;

  TestStats({
    required this.totalParticipants,
    required this.averageScore,
    required this.bestScore,
  });

  factory TestStats.fromJson(Map<String, dynamic> json) {
    return TestStats(
      totalParticipants: json['totalParticipants'],
      averageScore: json['averageScore'],
      bestScore: json['bestScore'],
    );
  }
}

class Score {
  final String id;
  final String user;
  final String test;
  final int totalQuestionsAttempted;
  final int totalCorrect;
  final int totalIncorrect;
  final num totalMarksObtained;
  final num totalMarks;
  final num accuracy;
  final num percentage;
  final num percentile;
  final int rank;
  final num timeTaken;
  final TestStats testStats;

  Score({
    required this.id,
    required this.user,
    required this.test,
    required this.totalQuestionsAttempted,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalMarksObtained,
    required this.totalMarks,
    required this.accuracy,
    required this.percentage,
    required this.percentile,
    required this.rank,
    required this.timeTaken,
    required this.testStats,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['_id'],
      user: json['user'],
      test: json['test'],
      totalQuestionsAttempted: json['totalQuestionsAttempted'],
      totalCorrect: json['totalCorrect'],
      totalIncorrect: json['totalIncorrect'],
      totalMarksObtained: json['totalMarksObtained'],
      totalMarks: json['totalMarks'],
      accuracy: json['accuracy'],
      percentage: json['percentage'],
      percentile: json['percentile'],
      rank: json['rank'],
      timeTaken: json['timeTaken'],
      testStats: TestStats.fromJson(json['testStats']),
    );
  }
}
