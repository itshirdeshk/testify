import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/mock_test.dart';
import 'package:testify/models/paginated_response.dart';
import 'package:testify/utils/custom_dio.dart';

class MockTestService {
  late final Dio _dio;

  MockTestService._create(this._dio);

  static Future<MockTestService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return MockTestService._create(dio);
  }

  Future<PaginatedResponse<MockTest>> getMockTestsPaginated(
    String testSeriesId, {
    int page = 1,
    int limit = 10,
    String? name,
  }) async {
    try {
      final response = await _dio.get(
        '/mockTest/mockTest/$testSeriesId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        },
      );

      if (response.statusCode == 200) {
        final mockTestsJson = response.data['mockTests'] ?? response.data['MockTests'];
        if (mockTestsJson is! List) {
          return PaginatedResponse<MockTest>(
            items: const [],
            pagination: PaginationMeta.fromJson(
              null,
              fallbackPage: page,
              fallbackLimit: limit,
              fallbackItemCount: 0,
            ),
          );
        }

        final mockTests = mockTestsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => MockTest.fromJson(json))
            .toList();

        final paginationJson = response.data['pagination'];
        final pagination = PaginationMeta.fromJson(
          paginationJson is Map<String, dynamic> ? paginationJson : null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: mockTests.length,
        );

        return PaginatedResponse<MockTest>(
          items: mockTests,
          pagination: pagination,
        );
      }
      return PaginatedResponse<MockTest>(
        items: const [],
        pagination: PaginationMeta.fromJson(
          null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: 0,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching mock tests: $e');
      }
      return PaginatedResponse<MockTest>(
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

  Future<List<MockTest>> getMockTests(String testSeriesId) async {
    final paginated = await getMockTestsPaginated(
      testSeriesId,
      page: 1,
      limit: 20,
    );
    return paginated.items;
  }
}
