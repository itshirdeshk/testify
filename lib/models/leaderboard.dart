class LeaderboardUser {
  final String id;
  final String name;
  final String? profilePicture;

  LeaderboardUser({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['_id'],
      name: json['name'],
      profilePicture: json['profilePicture'],
    );
  }
}

class LeaderboardScore {
  final String id;
  final num totalMarksObtained;
  final num totalMarks;

  LeaderboardScore({
    required this.id,
    required this.totalMarksObtained,
    required this.totalMarks,
  });

  factory LeaderboardScore.fromJson(Map<String, dynamic> json) {
    return LeaderboardScore(
      id: json['_id'],
      totalMarksObtained: json['totalMarksObtained'],
      totalMarks: json['totalMarks'],
    );
  }
}

class Leaderboard {
  final String id;
  final LeaderboardUser user;
  final String test;
  final LeaderboardScore score;
  final int rank;

  Leaderboard(
      {required this.id,
      required this.user,
      required this.test,
      required this.score,
      required this.rank});

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
        id: json['_id'],
        user: LeaderboardUser.fromJson(json['user']),
        test: json['test'],
        score: LeaderboardScore.fromJson(json['score']),
        rank: json['rank']);
  }
}
