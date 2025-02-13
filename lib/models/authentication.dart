class LoginCredentials {
  final String phone;
  final String password;

  LoginCredentials({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
      };
}

class OtpData {
  final String email;
  final String otp;

  OtpData({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': int.parse(otp),
      };
}

class ResetPasswordData {
  final String otp;
  final String password;
  final String confirmPassword;

  ResetPasswordData({
    required this.otp,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'otp': otp,
        'password': password,
        'password_confirmation': confirmPassword,
      };
}

class ChangePasswordData {
  final String oldPassword;
  final String newPassword;

  ChangePasswordData({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };
}