import 'package:equatable/equatable.dart';

class SignUpInputEntity extends Equatable {
  const SignUpInputEntity({
    required this.email,
    required this.password,
    required this.username,
    required this.phone,
  });

  final String email;
  final String password;
  final String username;
  final String phone;

  @override
  List<Object?> get props => [email, password, username, phone];
}
