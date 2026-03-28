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
      id: (json['_id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
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
    final rawOptions = json['options'];
    final optionList = rawOptions is List ? rawOptions : const <dynamic>[];

    return Question(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      options: optionList
          .whereType<Map<String, dynamic>>()
          .map((option) => Option.fromJson(option))
          .toList(),
      positiveMarks: (json['positiveMarks'] as num?)?.toDouble() ?? 0,
      negativeMarks: (json['negativeMarks'] as num?)?.toDouble() ?? 0,
      test: (json['test'] ?? '').toString(),
    );
  }

  bool get isCorrect {
    if (selectedOption == null) return false;
    if (selectedOption! < 0 || selectedOption! >= options.length) {
      return false;
    }
    return options[selectedOption!].isCorrect;
  }
}
