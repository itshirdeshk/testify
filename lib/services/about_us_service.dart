import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/about_us.dart';
import '../utils/custom_dio.dart';

class AboutUsService {
  late final Dio _dio;

  AboutUsService._create(this._dio);

  static Future<AboutUsService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return AboutUsService._create(dio);
  }

  Future<List<AboutUs>> fetchAboutUs() async {
    try {
      final response = await _dio.get('/all/about-us');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => AboutUs.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load About Us');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load About Us: ${e.message}');
    }
  }
}
