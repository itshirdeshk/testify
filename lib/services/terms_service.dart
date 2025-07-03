import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/terms.dart';
import '../utils/custom_dio.dart';

class TermsService {
  late final Dio _dio;

  TermsService._create(this._dio);

  static Future<TermsService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return TermsService._create(dio);
  }

  Future<List<Terms>> fetchTerms() async {
    try {
      final response = await _dio.get('/all/terms');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Terms.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load Terms');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load Terms: ${e.message}');
    }
  }
}
