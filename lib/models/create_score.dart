class CreateScore {
  final String? testId;
  final int totalQuestionsAttempted;
  final int totalCorrect;
  final int totalIncorrect;
  final int timeTaken;

  CreateScore({
    this.testId,
    required this.totalQuestionsAttempted,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.timeTaken,
  });
}
