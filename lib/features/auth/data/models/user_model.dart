import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({super.name, super.email, super.isVerified, super.uid});

  factory UserModel.fromFirebaseUser(User user) => UserModel(
    uid: user.uid,
    name: user.displayName ?? '',
    email: user.email ?? '',
    isVerified: user.emailVerified,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'isVerified': isVerified,
  };
}
