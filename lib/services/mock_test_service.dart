import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/mock_test.dart';
import 'package:testify/utils/custom_dio.dart';

class MockTestService {
  late final Dio _dio;

  MockTestService._create(this._dio);

  static Future<MockTestService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return MockTestService._create(dio);
  }

  Future<List<MockTest>> getMockTests(String testSeriesId) async {
    try {
      final response = await _dio.get('/mockTest/mockTest/$testSeriesId');
      if (response.statusCode == 200) {
        final List<dynamic> mockTestsJson = response.data['MockTests'];
        return mockTestsJson.map((json) => MockTest.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching mock tests: $e');
      }
      return [];
    }
  }
}
