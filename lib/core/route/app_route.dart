import 'package:flutter/material.dart';
import 'package:testify/custom/widgets/base_screen.dart';
import 'package:testify/views/authentication/change_password_screen.dart';
import 'package:testify/views/authentication/forgot_password_screen.dart';
import 'package:testify/views/authentication/otp_screen.dart';
import 'package:testify/views/authentication/reset_password_screen.dart';
import 'package:testify/views/exam/exam_screen.dart';
import 'package:testify/views/settings/settings.dart';
import 'package:testify/views/splash_screen/splash_screen.dart';
import 'package:testify/views/subscription/subscription.dart';
import 'package:testify/views/test/test_screen_main.dart';
import '../../views/profile/edit_profile_screen.dart' as profile_edit;
import 'package:testify/views/ranking/ranking_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/authentication/login_screen.dart';
import '../../views/authentication/signup_screen.dart';
import '../../views/home/home_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/otp':
        return MaterialPageRoute(
          builder: (context) {
            final args = settings.arguments as Map<String, dynamic>;
            return OtpScreen(
              email: args['email'] as String,
              screen: args['screen'] as bool,
            );
          },
        );
      default:
        final builder =
            _routes[settings.name] ?? (context) => const SplashScreen();
        return MaterialPageRoute(builder: builder);
    }
  }

  static final _routes = {
    '/login': (context) => const LoginScreen(),
    '/signup': (context) => const SignupScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/reset-password': (context) => const ResetPasswordScreen(),
    '/change_password': (context) => const ChangePasswordScreen(),
    '/exam': (context) => const ExamScreen(),
    '/home': (context) => const HomeScreen(),
    '/ranking': (context) => RankingScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/edit_profile': (context) => const profile_edit.EditProfileScreen(),
    '/test_screen_main': (context) => const TestScreenMain(),
    '/subscription': (context) => const SubscriptionScreen(),
    '/splash_screen': (context) => const SplashScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/base_screen': (context) => const BaseScreen(),
  };
}
