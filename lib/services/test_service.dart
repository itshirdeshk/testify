import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/test.dart';
import 'package:testify/utils/custom_dio.dart';

class TestService {
  late final Dio _dio;

  TestService._create(this._dio);

  static Future<TestService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return TestService._create(dio);
  }

  Future<TestResponse> getTests(String mockTestId) async {
    try {
      final response = await _dio.get('/test/test/$mockTestId');
      if (response.statusCode == 200) {
        final testsJson = response.data['unattemptedTests'];
        final previouslyAttemptedTestsJson = response.data['attemptedTests'];

        if (testsJson is! List || previouslyAttemptedTestsJson is! List) {
          return TestResponse(unattemptedTests: [], attemptedTests: []);
        }

        final tests = testsJson.map((json) => Test.fromJson(json)).toList();
        final previouslyAttemptedTests = previouslyAttemptedTestsJson
          .map((json) =>
            json is Map<String, dynamic> ? json['test'] : null)
          .whereType<Map<String, dynamic>>()
          .map((json) => Test.fromJson(json))
            .toList();
        return TestResponse(
            unattemptedTests: tests, attemptedTests: previouslyAttemptedTests);
        // return TestResponse.fromJson({
        //   'unattemptedTests': testsJson,
        //   'attemptedTests': previouslyAttemptedTestsJson
        // });
      }
      return TestResponse(unattemptedTests: [], attemptedTests: []);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tests: $e');
      }
      return TestResponse(unattemptedTests: [], attemptedTests: []);
    }
  }
}
