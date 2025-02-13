class Option {
  final String id;
  final String text;
  final bool isCorrect;

  Option({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['_id'],
      text: json['text'],
      isCorrect: json['isCorrect'],
    );
  }
}

class Question {
  final String id;
  final String title;
  final List<Option> options;
  final double positiveMarks;
  final double negativeMarks;
  final String test;
  int? selectedOption; // To track user's answer

  Question({
    required this.id,
    required this.title,
    required this.options,
    required this.positiveMarks,
    required this.negativeMarks,
    required this.test,
    this.selectedOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'],
      title: json['title'],
      options: (json['options'] as List)
          .map((option) => Option.fromJson(option))
          .toList(),
      positiveMarks: json['positiveMarks'].toDouble(),
      negativeMarks: json['negativeMarks'].toDouble(),
      test: json['test'],
    );
  }

  bool get isCorrect {
    if (selectedOption == null) return false;
    return options[selectedOption!].isCorrect;
  }
}
