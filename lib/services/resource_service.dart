import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/resource.dart';
import 'package:testify/utils/custom_dio.dart';
import 'package:http/http.dart' as http;
import 'package:testify/widgets/custom_toast.dart';

class ResourceService {
  late final Dio _dio;
  static const String downloadPath = 'storage/emulated/0/Download';

  ResourceService._create(this._dio);

  static Future<ResourceService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return ResourceService._create(dio);
  }

  Future<List<Resource>> getResources(String subExamId) async {
    try {
      final response = await _dio.get('/resource/resource/$subExamId');

      if (response.statusCode == 200) {
        final List<dynamic> resourcesJson = response.data['resources'];
        return resourcesJson.map((json) => Resource.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch resources');
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Error fetching resources: $e');
    }
  }

  Future<void> _ensureDirectoryExists() async {
    final directory = Directory(downloadPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> _saveFile(List<int> bytes, String filePath) async {
    final file = File(filePath);
    await file.writeAsBytes(bytes);
  }

  void _showMessage(BuildContext context, String message,
      {bool isError = false}) {
    if (context.mounted) {
      CustomToast.show(
        context: context,
        message: message,
        isError: isError,
      );
    }
  }

  Future<String> downloadResource(
      String url, String title, String type, BuildContext context) async {
    try {
      await _ensureDirectoryExists();

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        if (context.mounted) {
          _showMessage(context, 'Failed to download resource', isError: true);
        }
        throw Exception('Download failed: ${response.statusCode}');
      }

      final filePath = '$downloadPath/$title.$type';
      await _saveFile(response.bodyBytes, filePath);

      if (context.mounted) {
        _showMessage(context, 'Resource downloaded successfully');
      }
      return filePath;
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, 'An error occurred while downloading',
            isError: true);
      }
      throw Exception('Download error: $e');
    }
  }
}
