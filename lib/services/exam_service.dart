import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/exam.dart';
import 'package:testify/models/paginated_response.dart';
import 'package:testify/utils/custom_dio.dart';

class ExamService {
  late final Dio _dio;

  ExamService._create(this._dio);

  static Future<ExamService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return ExamService._create(dio);
  }

  Future<PaginatedResponse<Exam>> getAllExamsPaginated({
    int page = 1,
    int limit = 10,
    String? name,
  }) async {
    try {
      final response = await _dio.get(
        '/exam',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        },
      );

      if (response.statusCode == 200) {
        final examsJson = response.data['exams'];
        if (examsJson is! List) {
          return PaginatedResponse<Exam>(
            items: const [],
            pagination: PaginationMeta.fromJson(
              null,
              fallbackPage: page,
              fallbackLimit: limit,
              fallbackItemCount: 0,
            ),
          );
        }

        final exams = examsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Exam.fromJson(json))
            .toList();

        final paginationJson = response.data['pagination'];
        final pagination = PaginationMeta.fromJson(
          paginationJson is Map<String, dynamic> ? paginationJson : null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: exams.length,
        );

        return PaginatedResponse<Exam>(
          items: exams,
          pagination: pagination,
        );
      }
      return PaginatedResponse<Exam>(
        items: const [],
        pagination: PaginationMeta.fromJson(
          null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: 0,
        ),
      );
    } on DioException {
      return PaginatedResponse<Exam>(
        items: const [],
        pagination: PaginationMeta.fromJson(
          null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: 0,
        ),
      );
    }
  }

  Future<List<Exam>> getAllExams() async {
    final paginated = await getAllExamsPaginated(page: 1, limit: 20);
    return paginated.items;
  }
}
