import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testify/core/route/app_route.dart';
import 'package:testify/core/theme/app_theme.dart';
import 'package:testify/providers/test_provider.dart';
import 'package:testify/providers/user_provider.dart';
import 'package:testify/providers/theme_provider.dart';
import 'views/faq/faq_screen.dart';
import 'views/about_us/about_us_screen.dart';
import 'views/privacy_policy/privacy_policy_screen.dart';
import 'views/terms/terms_screen.dart';
import 'custom/widgets/base_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:testify/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService.instance.initialize(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/splash_screen',
          onGenerateRoute: AppRoutes.generateRoute,
          debugShowCheckedModeBanner: false,
          home: const BaseScreen(),
          routes: {
            '/faq': (context) => const FAQScreen(),
            '/about-us': (context) => const AboutUsScreen(),
            '/privacy-policy': (context) => const PrivacyPolicyScreen(),
            '/terms': (context) => const TermsScreen(),
          },
        );
      },
    );
  }
}
