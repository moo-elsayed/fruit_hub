import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.name,
    super.email,
    this.password,
    required this.isVerified,
    required this.id,
  });

  final String id;
  final String? password;
  final bool isVerified;

  factory UserModel.fromFirebaseUser(User user) => UserModel(
    id: user.uid,
    name: user.displayName ?? '',
    email: user.email ?? '',
    isVerified: user.emailVerified,
  );
}
