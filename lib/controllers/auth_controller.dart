import 'package:flutter/material.dart';
import 'package:testify/models/authentication.dart';
import '../services/auth_service.dart';
import '../models/registration_data.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_toast.dart';
import 'package:flutter/foundation.dart';

class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());

  bool _hasCompletedExamSelection(UserProvider userProvider) {
    final examId = (userProvider.user?.examId ?? '').trim();
    final subExamId = (userProvider.user?.subExamId ?? '').trim();
    return examId.isNotEmpty && subExamId.isNotEmpty;
  }

  Future<bool> login(BuildContext context) async {
    final AuthService authService = AuthService();
    try {
      final response = await authService.login(
          LoginCredentials(
              phone: phoneController.text, password: passwordController.text),
          context);
      if (response.statusCode == 200 && context.mounted) {
        CustomToast.show(
          context: context,
          message: 'Login Successful',
        );

        if (response.data['user']['isUserVerified'] == true) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final hasCompletedSelection =
              _hasCompletedExamSelection(userProvider);

          if (!hasCompletedSelection) {
            Navigator.pushNamed(
              context,
              '/exam',
            );
            return true;
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/base_screen',
              (route) => false,
            );
            return true;
          }
        } else {
          Navigator.pushNamed(context, '/otp',
              arguments: {"email": emailController.text, "screen": false});

          return true;
        }
      } else {
        if (context.mounted) {
          final message = response.data is Map<String, dynamic>
              ? (response.data['message'] ?? 'Login failed').toString()
              : 'Login failed';

          CustomToast.show(
            context: context,
            message: message,
            isError: true,
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during login: $e");
      }
      return false;
    }
  }

  Future<bool> register(BuildContext context) async {
    final AuthService authService = AuthService();
    try {
      final registrationData = RegistrationData(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        phone: phoneController.text,
      );

      final response = await authService.register(registrationData, context);
      if (response.statusCode == 201 && context.mounted) {
        CustomToast.show(
          context: context,
          message: 'Registration Successful',
        );
        Navigator.pushNamed(context, '/otp',
            arguments: {"email": emailController.text, "screen": true});
        return true;
      } else {
        if (context.mounted) {
          final message = response.data is Map<String, dynamic>
              ? (response.data['message'] ?? 'Registration failed').toString()
              : 'Registration failed';

          CustomToast.show(
            context: context,
            message: message,
            isError: true,
          );
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(
      BuildContext context, String email, bool screen) async {
    final AuthService authService = AuthService();
    try {
      String otp = otpControllers.map((controller) => controller.text).join();
      final response =
          await authService.verifyOtp(OtpData(email: email, otp: otp), context);

      if (response.statusCode == 200 && context.mounted) {
        CustomToast.show(
          context: context,
          message: 'Verify OTP Successful',
        );

        // If screen is true, directly go to exam screen
        if (screen) {
          Navigator.pushNamed(
            context,
            '/exam',
          );
          return true;
        }

        // Check examId from user provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (!_hasCompletedExamSelection(userProvider)) {
          Navigator.pushNamed(
            context,
            '/exam',
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/base_screen',
            (route) => false,
          );
        }
        return true;
      }
      if (context.mounted) {
        final message = response.data is Map<String, dynamic>
            ? (response.data['message'] ?? 'OTP verification failed').toString()
            : 'OTP verification failed';

        CustomToast.show(
          context: context,
          message: message,
          isError: true,
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
  }
}
