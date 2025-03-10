import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testify/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:testify/widgets/custom_toast.dart';

class CustomDio {
  static Future<Dio> create(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token =
        prefs.getString('token'); // Retrieve token from shared preferences

    final dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl, // Set your base URL here
      headers: {
        if (token != null)
          'Authorization': 'Bearer $token', // Add Bearer token if available
      },
    ));

    // Add interceptors if needed
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Modify request options before sending
        if (kDebugMode) {
          print('Request: ${options.method} ${options.path}');
        }
        return handler.next(options); // Continue with the request
      },
      onResponse: (response, handler) {
        // Handle response
        if (kDebugMode) {
          print('Response: ${response.statusCode} ${response.data}');
        }
        return handler.next(response); // Continue with the response
      },
      onError: (DioException e, handler) {
        // Handle errors
        if (e.response?.statusCode == 401) {
          print(e.response.toString());
          // Handle unauthorized error
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
          CustomToast.show(
              context: context,
              message: 'Token Expired, Login Again.',
              isError: true);
          return handler.next(e);
        }
        if (kDebugMode) {
          print('Error: ${e.message}');
        }
        return handler.next(e); // Continue with the error
      },
    ));

    return dio;
  }
}
