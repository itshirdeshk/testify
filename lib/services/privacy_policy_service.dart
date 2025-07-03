import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/privacy_policy.dart';
import '../utils/custom_dio.dart';

class PrivacyPolicyService {
  late final Dio _dio;

  PrivacyPolicyService._create(this._dio);

  static Future<PrivacyPolicyService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return PrivacyPolicyService._create(dio);
  }

  Future<List<PrivacyPolicy>> fetchPrivacyPolicies() async {
    try {
      final response = await _dio.get('/all/privacy-policy');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => PrivacyPolicy.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load Privacy Policies');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load Privacy Policies: ${e.message}');
    }
  }
}
