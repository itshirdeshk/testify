import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/banner.dart' as Banner;
import 'package:testify/models/test_series.dart';
import 'package:testify/utils/custom_dio.dart';

class TestSeriesService {
  late final Dio _dio;
  static List<TestSeries> _cachedTestSeries = [];
  static List<Banner.Banner> _cachedBanners = [];

  TestSeriesService._create(this._dio);

  static Future<TestSeriesService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return TestSeriesService._create(dio);
  }

  Future<List<TestSeries>> getTestSeries(String subExamId,
      {bool forceRefresh = false}) async {

    if (_cachedTestSeries.isNotEmpty && !forceRefresh) {
      return _cachedTestSeries;
    }

    try {
      final response = await _dio.get('/testSeries/testSeries/$subExamId');
      if (response.statusCode == 200) {
        final List<dynamic> testSeriesJson = response.data['TestSeries'];
        _cachedTestSeries =
            testSeriesJson.map((json) => TestSeries.fromJson(json)).toList();
        return _cachedTestSeries;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching test series: $e');
      }
      return [];
    }
  }

  Future<List<Banner.Banner>> getBanners(String subExamId,
      {bool forceRefresh = false}) async {

    if (_cachedBanners.isNotEmpty && !forceRefresh) {
      return _cachedBanners;
    }

    try {
      final response = await _dio.get('/banner/banner/$subExamId'); 
      if (response.statusCode == 200) {
        final List<dynamic> bannersJson = response.data['banners'];
        _cachedBanners =
            bannersJson.map((json) => Banner.Banner.fromJson(json)).toList();
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
