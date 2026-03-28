import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/paginated_response.dart';
import 'package:testify/models/sub_exam.dart';
import 'package:testify/utils/custom_dio.dart';

class SubExamService {
  late final Dio _dio;

  SubExamService._create(this._dio);

  static Future<SubExamService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return SubExamService._create(dio);
  }

  Future<PaginatedResponse<SubExam>> getSubExamsPaginated(
    String examId, {
    int page = 1,
    int limit = 10,
    String? name,
  }) async {
    try {
      final response = await _dio.get(
        '/subExam/subExam/$examId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        },
      );

      if (response.statusCode == 200) {
        final subExamsJson = response.data['subExams'];
        if (subExamsJson is! List) {
          return PaginatedResponse<SubExam>(
            items: const [],
            pagination: PaginationMeta.fromJson(
              null,
              fallbackPage: page,
              fallbackLimit: limit,
              fallbackItemCount: 0,
            ),
          );
        }

        final subExams = subExamsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => SubExam.fromJson(json))
            .toList();

        final paginationJson = response.data['pagination'];
        final pagination = PaginationMeta.fromJson(
          paginationJson is Map<String, dynamic> ? paginationJson : null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: subExams.length,
        );

        return PaginatedResponse<SubExam>(
          items: subExams,
          pagination: pagination,
        );
      }
      return PaginatedResponse<SubExam>(
        items: const [],
        pagination: PaginationMeta.fromJson(
          null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: 0,
        ),
      );
    } on DioException {
      return PaginatedResponse<SubExam>(
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

  Future<List<SubExam>> getSubExams(String examId) async {
    final paginated = await getSubExamsPaginated(examId, page: 1, limit: 20);
    return paginated.items;
  }
}
