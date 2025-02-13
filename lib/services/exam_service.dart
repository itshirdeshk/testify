import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/exam.dart';
import 'package:testify/utils/custom_dio.dart';

class ExamService {
  late final Dio _dio;

  ExamService._create(this._dio);

  static Future<ExamService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return ExamService._create(dio);
  }

  Future<List<Exam>> getAllExams() async {
    try {
      final response = await _dio.get('/exam');

      if (response.statusCode == 200) {
        final List<dynamic> examsJson = response.data['exams'];
        return examsJson.map((json) => Exam.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
