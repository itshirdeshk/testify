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
  bool _isInitialized = false;

  AuthService();

  Future<void> init(BuildContext context) async {
    if (!_isInitialized) {
      _dio = await CustomDio.create(context);
      _isInitialized = true;
    }
  }

  Response _handleDioException(DioException e) {
    return Response(
      requestOptions: e.requestOptions,
      statusCode: e.response?.statusCode ?? 500,
      statusMessage: e.message,
      data: e.response?.data,
    );
  }

  Future<Response> _makePostRequest(
      String endpoint, Map<String, dynamic> data, BuildContext context) async {
    await init(context); // Ensure Dio is initialized before request
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> login(LoginCredentials credentials, BuildContext context) async {
    final response = await _makePostRequest('/user/login', credentials.toJson(), context);

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
    }
    return response;
  }

  Future<Response> register(RegistrationData data, BuildContext context) async {
    final response = await _makePostRequest('/user/register', data.toJson(), context);

    if (response.statusCode == 201) {
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      final userData = response.data['newUser'];
      final user = User(
        id: userData['_id'],
        name: userData['name'],
        email: userData['email'],
        phone: userData['phone'].toString(),
      );

      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }
    }
    return response;
  }

  Future<Response> verifyOtp(OtpData otpData, BuildContext context) async {
    return _makePostRequest('/user/verify/otp', otpData.toJson(), context);
  }

  Future<Response> sendResetPasswordEmail(String email, BuildContext context) async {
    return _makePostRequest('/user/send-reset-password-email', {'email': email}, context);
  }

  Future<Response> sendOtpAgain(String email, BuildContext context) async {
    return _makePostRequest('/user/send-otp-again', {'email': email}, context);
  }

  Future<Response> resetPassword(ResetPasswordData resetData, BuildContext context) async {
    return _makePostRequest('/user/reset-password', resetData.toJson(), context);
  }

  Future<Response> changePassword(ChangePasswordData changeData, BuildContext context) async {
    return _makePostRequest('/user/changePassword', changeData.toJson(), context);
  }
}
