class LoginCredentials {
  final String emailOrPhone;
  final String password;
  final bool rememberMe;

  LoginCredentials({
    required this.emailOrPhone,
    required this.password,
    required this.rememberMe,
  });

  // Convert to JSON / Map if needed for backend API
  Map<String, dynamic> toJson() {
    return {
      'email_or_phone': emailOrPhone,
      'password': password,
      'remember_me': rememberMe,
    };
  }

  // Factory constructor for creating credentials from json/map
  factory LoginCredentials.fromJson(Map<String, dynamic> json) {
    return LoginCredentials(
      emailOrPhone: json['email_or_phone'] ?? '',
      password: json['password'] ?? '',
      rememberMe: json['remember_me'] ?? false,
    );
  }
}
