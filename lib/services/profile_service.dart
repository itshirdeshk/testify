import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:testify/utils/custom_dio.dart';
import 'package:testify/models/user.dart';
import 'package:testify/models/profile_update.dart';

class ProfileService {
  late Dio _dio;
  bool _isInitialized = false;

  ProfileService();

  Future<void> init(BuildContext context) async {
    if (!_isInitialized) {
      _dio = await CustomDio.create(context);
      _isInitialized = true;
    }
  }

  Future<User?> updateProfile(ProfileUpdate data, BuildContext context) async {
    await init(context);
    try {
      final formData = FormData.fromMap({
        if (data.name != null) 'name': data.name,
        if (data.email != null) 'email ': data.email,
        if (data.phone != null) 'phone': data.phone,
        if (data.examId != null) 'examId': data.examId,
        if (data.subExamId != null) 'subExamId': data.subExamId,
        if (data.profilePicture != null)
          'image': await MultipartFile.fromFile(data.profilePicture!),
      });

      final response = await _dio.put('/user/updateProfile', data: formData);

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        return User(
          id: userData['_id'],
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'].toString(),
          examId: userData['exam'],
          subExamId: userData['subExam'],
          examName: userData['examName'],
          subExamName: userData['subExamName'],
          profilePicture: userData['profilePicture'] ?? '',
          premium: userData['isPremium'],
        );
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
