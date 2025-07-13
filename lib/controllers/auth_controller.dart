import 'package:flutter/material.dart';
import 'package:testify/models/authentication.dart';
import '../services/auth_service.dart';
import '../models/registration_data.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_toast.dart';

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
          final examId = userProvider.user?.examId;

          // Navigate based on examId
          if (examId == '') {
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
        } else {
          Navigator.pushNamed(context, '/otp',
              arguments: {"email": emailController.text, "screen": false});
        }
        return true;
      } else {
        if (context.mounted) {
          CustomToast.show(
            context: context,
            message: response.data['message'],
            isError: true,
          );
        }
        return false;
      }
    } catch (e) {
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
          CustomToast.show(
            context: context,
            message: response.data['message'],
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
        final examId = userProvider.user?.examId;

        // Navigate based on examId
        if (examId == '') {
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
        CustomToast.show(
          context: context,
          message: response.data['message'],
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
