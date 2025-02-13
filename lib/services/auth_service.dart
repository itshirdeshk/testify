import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testify/models/authentication.dart';
import 'package:testify/models/registration_data.dart';
import 'package:testify/models/user.dart';
import 'package:testify/utils/custom_dio.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:flutter/material.dart';

class AuthService {
  late Dio _dio;

  AuthService(BuildContext context) {
    CustomDio.create(context).then((dio) => _dio = dio);
  }

  // Helper method to handle DioException and return a Response
  Response _handleDioException(DioException e) {
    return Response(
      requestOptions: e.requestOptions,
      statusCode: e.response?.statusCode ?? 500,
      statusMessage: e.message,
      data: e.response?.data,
    );
  }

  // Helper method to make a POST request and handle errors
  Future<Response> _makePostRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> login(
      LoginCredentials credentials, BuildContext context) async {
    try {
      final response =
          await _makePostRequest('/user/login', credentials.toJson());

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final userData = response.data['user'];

        final user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'].toString(),
          examId: userData['exam']['_id'],
          subExamId: userData['subExam']['_id'],
          examName: userData['exam']['name'],
          subExamName: userData['subExam']['name'],
          profilePicture: userData['profilePicture'] ?? '',
        );

        if (context.mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        }
        return response;
      }
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> register(RegistrationData data, BuildContext context) async {
    try {
      final response = await _makePostRequest('/user/register', data.toJson());
      if (response.statusCode == 201) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final userData = response.data['newUser'];
        final user = User(
            id: userData['_id'],
            name: userData['name'],
            email: userData['email'],
            phone: userData['phone'].toString());

        if (context.mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        }

        return response;
      }
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> verifyOtp(OtpData otpData) async {
    return _makePostRequest('/user/verify/otp', otpData.toJson());
  }

  Future<Response> sendResetPasswordEmail(String email) async {
    return _makePostRequest('/user/send-reset-password-email', {
      'email': email,
    });
  }

  Future<Response> resetPassword(ResetPasswordData resetData) async {
    return _makePostRequest('/user/reset-password', resetData.toJson());
  }

  Future<Response> changePassword(ChangePasswordData changeData) async {
    return _makePostRequest('/user/changePassword', changeData.toJson());
  }
}
