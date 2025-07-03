// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  UserProvider() {
    _loadFromPrefs();
  }

  Future<void> setUser(User user) async {
    _user = user;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
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
    if (userStr != null) {
      final userData = jsonDecode(userStr);
      _user = User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        phone: userData['phone'],
        profilePicture: userData['profilePicture'],
        examId: userData['examId'],
        subExamId: userData['subExamId'],
        examName: userData['examName'],
        subExamName: userData['subExamName'],
        premium: userData['premium'],
      );
      notifyListeners();
    }
  }
}
