/// The authenticated user returned by the backend on login.
class AuthUser {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? authProvider;
  final String? role;

  AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.authProvider,
    this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      authProvider: json['authProvider'],
      role: json['role'],
    );
  }
}

/// The result of a successful login: the JWT plus the user it belongs to.
class AuthSession {
  final String token;
  final String tokenType;
  final AuthUser user;

  AuthSession({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
