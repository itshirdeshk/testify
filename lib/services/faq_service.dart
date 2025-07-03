import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/faq.dart';
import '../utils/custom_dio.dart';

class FAQService {
  late final Dio _dio;

  FAQService._create(this._dio);

  static Future<FAQService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return FAQService._create(dio);
  }

  Future<List<FAQ>> fetchFAQs() async {
    try {
      final response = await _dio.get('/all/faq');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => FAQ.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load FAQs');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load FAQs: ${e.message}');
    }
  }
}
