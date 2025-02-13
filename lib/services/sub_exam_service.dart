import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/sub_exam.dart';
import 'package:testify/utils/custom_dio.dart';

class SubExamService {
  late final Dio _dio;

  SubExamService._create(this._dio);

  static Future<SubExamService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return SubExamService._create(dio);
  }

  Future<List<SubExam>> getSubExams(String examId) async {
    try {
      final response = await _dio.get('/subExam/subExam/$examId');

      if (response.statusCode == 200) {
        final List<dynamic> subExamsJson = response.data['subExams'];
        return subExamsJson.map((json) => SubExam.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
