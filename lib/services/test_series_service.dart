import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/banner.dart' as banner_model;
import 'package:testify/models/paginated_response.dart';
import 'package:testify/models/test_series.dart';
import 'package:testify/utils/custom_dio.dart';

class TestSeriesService {
  late final Dio _dio;
  static List<banner_model.Banner> _cachedBanners = [];

  TestSeriesService._create(this._dio);

  static Future<TestSeriesService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return TestSeriesService._create(dio);
  }

  Future<PaginatedResponse<TestSeries>> getTestSeriesPaginated(
    String subExamId, {
    int page = 1,
    int limit = 10,
    String? name,
  }) async {

    try {
      final response = await _dio.get(
        '/testSeries/testSeries/$subExamId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        },
      );

      if (response.statusCode == 200) {
        final testSeriesJson =
            response.data['testSeries'] ?? response.data['TestSeries'];
        if (testSeriesJson is! List) {
          return PaginatedResponse<TestSeries>(
            items: const [],
            pagination: PaginationMeta.fromJson(
              null,
              fallbackPage: page,
              fallbackLimit: limit,
              fallbackItemCount: 0,
            ),
          );
        }

        final testSeries = testSeriesJson
            .whereType<Map<String, dynamic>>()
            .map((json) => TestSeries.fromJson(json))
            .toList();

        final paginationJson = response.data['pagination'];
        final pagination = PaginationMeta.fromJson(
          paginationJson is Map<String, dynamic> ? paginationJson : null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: testSeries.length,
        );

        return PaginatedResponse<TestSeries>(
          items: testSeries,
          pagination: pagination,
        );
      }
      return PaginatedResponse<TestSeries>(
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
        print('Error fetching test series: $e');
      }
      return PaginatedResponse<TestSeries>(
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

  Future<List<TestSeries>> getTestSeries(
    String subExamId, {
    bool forceRefresh = false,
  }) async {
    final paginated = await getTestSeriesPaginated(
      subExamId,
      page: 1,
      limit: 20,
    );

    if (forceRefresh) {
      _cachedBanners = [];
    }

    return paginated.items;
  }

  Future<List<banner_model.Banner>> getBanners(String subExamId,
      {bool forceRefresh = false}) async {

    if (_cachedBanners.isNotEmpty && !forceRefresh) {
      return _cachedBanners;
    }

    try {
      final response = await _dio.get('/banner/banner/$subExamId'); 
      if (response.statusCode == 200) {
        final bannersJson = response.data['banners'];
        if (bannersJson is! List) {
          return [];
        }

        _cachedBanners =
          bannersJson.map((json) => banner_model.Banner.fromJson(json)).toList();
        return _cachedBanners;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching test series: $e');
      }
      return [];
    }
  }
}
