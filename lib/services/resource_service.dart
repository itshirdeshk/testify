import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/paginated_response.dart';
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

  Future<PaginatedResponse<Resource>> getResourcesPaginated(
    String subExamId, {
    int page = 1,
    int limit = 10,
    String? title,
  }) async {
    try {
      final response = await _dio.get(
        '/resource/resource/$subExamId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        },
      );

      if (response.statusCode == 200) {
        final resourcesJson = response.data['resources'];
        if (resourcesJson is! List) {
          return PaginatedResponse<Resource>(
            items: const [],
            pagination: PaginationMeta.fromJson(
              null,
              fallbackPage: page,
              fallbackLimit: limit,
              fallbackItemCount: 0,
            ),
          );
        }

        final resources = resourcesJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Resource.fromJson(json))
            .toList();

        final paginationJson = response.data['pagination'];
        final pagination = PaginationMeta.fromJson(
          paginationJson is Map<String, dynamic> ? paginationJson : null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: resources.length,
        );

        return PaginatedResponse<Resource>(
          items: resources,
          pagination: pagination,
        );
      }
      throw Exception('Failed to fetch resources');
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Error fetching resources: $e');
    }
  }

  Future<List<Resource>> getResources(
    String subExamId, {
    String? title,
  }) async {
    final paginated = await getResourcesPaginated(
      subExamId,
      page: 1,
      limit: 20,
      title: title,
    );
    return paginated.items;
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
