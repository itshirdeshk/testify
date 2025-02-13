// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  String profilePicture;
  String? examId;
  String? subExamId;
  String? examName;
  String? subExamName;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      this.profilePicture = '',
      this.examId = '',
      this.subExamId = '',
      this.examName = '',
      this.subExamName = ''});
}
