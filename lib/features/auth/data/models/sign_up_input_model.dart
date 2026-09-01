import 'package:fruit_hub/features/auth/domain/entities/sign_up_input_entity.dart';

class SignUpInputModel {
  const SignUpInputModel({
    required this.email,
    required this.password,
    required this.username,
    required this.phone,
  });

  factory SignUpInputModel.fromEntity(SignUpInputEntity entity) =>
      SignUpInputModel(
        email: entity.email,
        password: entity.password,
        username: entity.username,
        phone: entity.phone,
      );

  factory SignUpInputModel.fromJson(Map<String, dynamic> json) =>
      SignUpInputModel(
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        username: json['username'] ?? '',
        phone: json['phone'] ?? '',
      );

  final String email;
  final String password;
  final String username;
  final String phone;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'username': username,
    'phone': phone,
  };

  SignUpInputEntity toEntity() => SignUpInputEntity(
    email: email,
    password: password,
    username: username,
    phone: phone,
  );
}
