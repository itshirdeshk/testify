class RegistrationData {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String confirmPassword;

  RegistrationData({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'phone': int.parse(phone),
    'password': password,
    'password_confirmation': confirmPassword,
  };
} 