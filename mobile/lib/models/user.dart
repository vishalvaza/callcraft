import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final bool isActive;
  final bool isVerified;
  final String subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    required this.isActive,
    required this.isVerified,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get displayName => fullName ?? email.split('@')[0];

  bool get isPaidUser => subscriptionTier != 'free';

  String get subscriptionDisplayName {
    switch (subscriptionTier) {
      case 'basic':
        return 'Basic';
      case 'pro':
        return 'Pro';
      case 'free':
      default:
        return 'Free';
    }
  }
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String? fullName;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    this.tokenType = 'bearer',
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
