import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testify/models/create_score.dart';
import 'package:testify/models/leaderboard.dart';
import 'package:testify/models/paginated_response.dart';
import 'package:testify/models/score.dart';
import 'package:testify/utils/custom_dio.dart';

class ScoreService {
  late final Dio _dio;

  ScoreService._create(this._dio);

  static Future<ScoreService> create(BuildContext context) async {
    final dio = await CustomDio.create(context);
    return ScoreService._create(dio);
  }

  Future<Score> createScore(CreateScore score) async {
    try {
      final response = await _dio.post('/score/create', data: {
        'testId': score.testId,
        'totalQuestionsAttempted': score.totalQuestionsAttempted,
        'totalCorrect': score.totalCorrect,
        'totalIncorrect': score.totalIncorrect,
        'timeTaken': score.timeTaken,
      });

      if (response.statusCode == 201) {
        return Score.fromJson(response.data['score']);
      }
      throw Exception('Failed to create score');
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Error creating score: $e');
    }
  }

  Future<Score> updateScore(CreateScore score) async {
    final String testId = score.testId!;
    try {
      final response = await _dio.put('/score/update/$testId', data: {
        'totalQuestionsAttempted': score.totalQuestionsAttempted,
        'totalCorrect': score.totalCorrect,
        'totalIncorrect': score.totalIncorrect,
        'timeTaken': score.timeTaken,
      });

      if (response.statusCode == 200) {
        return Score.fromJson(response.data['score']);
      }
      throw Exception('Failed to update score');
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Error updating score: $e');
    }
  }

  Future<Score> fetchScore(String testId) async {
    try {
      final response = await _dio.get('/score/test/$testId');

      if (response.statusCode == 200) {
        return Score.fromJson(response.data['score'][0]);
      }
      throw Exception('Failed to fetch score');
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Error fetching score: $e');
    }
  }

  Future<PaginatedResponse<Leaderboard>> getLeaderboardPaginated(
    String testId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/leaderboard/leaderboard/$testId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final leaderboardJson = response.data['leaderboard'];
        if (leaderboardJson is! List) {
          return PaginatedResponse<Leaderboard>(
            items: const [],
            pagination: PaginationMeta.fromJson(
              null,
              fallbackPage: page,
              fallbackLimit: limit,
              fallbackItemCount: 0,
            ),
          );
        }

        final leaderboard = leaderboardJson
            .whereType<Map<String, dynamic>>()
            .map((e) => Leaderboard.fromJson(e))
            .toList();

        final paginationJson = response.data['pagination'];
        final pagination = PaginationMeta.fromJson(
          paginationJson is Map<String, dynamic> ? paginationJson : null,
          fallbackPage: page,
          fallbackLimit: limit,
          fallbackItemCount: leaderboard.length,
        );

        return PaginatedResponse<Leaderboard>(
          items: leaderboard,
          pagination: pagination,
        );
      }
      throw Exception('Failed to fetch leaderboard');
    } catch (e) {
      if (kDebugMode) {
        print('API Error Leaderboard: $e');
      }
      throw Exception('Error fetching leaderboard: $e');
    }
  }

  Future<List<Leaderboard>> getLeaderboard(String testId) async {
    final paginated = await getLeaderboardPaginated(
      testId,
      page: 1,
      limit: 20,
    );
    return paginated.items;
  }
}
