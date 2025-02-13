import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/question.dart';
import 'package:testify/utils/custom_dio.dart';

class QuestionService {
  late final Dio _dio;

  QuestionService._create(this._dio);

  static Future<QuestionService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return QuestionService._create(dio);
  }

  Future<List<Question>> getQuestions(String testId) async {
    try {
      final response = await _dio.get('/question/question/$testId');
      if (response.statusCode == 200) {
        final List<dynamic> questionsJson = response.data['questions'];
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching questions: $e');
      }
      return [];
    }
  }
}
