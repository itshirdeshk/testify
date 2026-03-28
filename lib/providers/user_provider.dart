// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isInitialized => _isInitialized;
  bool get hasCompletedExamSelection {
    final examId = (_user?.examId ?? '').trim();
    final subExamId = (_user?.subExamId ?? '').trim();
    return examId.isNotEmpty && subExamId.isNotEmpty;
  }

  UserProvider() {
    _loadFromPrefs();
  }

  Future<void> setUser(User user) async {
    _user = user;
    _isInitialized = true;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    _isInitialized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      final userData = {
        'id': _user!.id,
        'name': _user!.name,
        'email': _user!.email,
        'phone': _user!.phone,
        'profilePicture': _user!.profilePicture,
        'examId': _user!.examId,
        'subExamId': _user!.subExamId,
        'examName': _user!.examName,
        'subExamName': _user!.subExamName,
        'premium': _user!.premium,
      };
      await prefs.setString('user_data', jsonEncode(userData));
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null && userStr.isNotEmpty) {
      try {
        final userData = jsonDecode(userStr) as Map<String, dynamic>;
        _user = User(
          id: (userData['id'] ?? '').toString(),
          name: (userData['name'] ?? '').toString(),
          email: (userData['email'] ?? '').toString(),
          phone: (userData['phone'] ?? '').toString(),
          profilePicture: (userData['profilePicture'] ?? '').toString(),
          examId: (userData['examId'] ?? '').toString(),
          subExamId: (userData['subExamId'] ?? '').toString(),
          examName: (userData['examName'] ?? '').toString(),
          subExamName: (userData['subExamName'] ?? '').toString(),
          premium: userData['premium'] == true,
        );
      } catch (_) {
        _user = null;
        await prefs.remove('user_data');
      }
    }

    _isInitialized = true;
    notifyListeners();
  }
}
