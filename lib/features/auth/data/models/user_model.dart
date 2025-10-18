import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({super.name, super.email, super.isVerified, super.uid});

  factory UserModel.fromFirebaseUser(User user) => UserModel(
    uid: user.uid,
    name: user.displayName,
    email: user.email,
    isVerified: user.emailVerified,
  );

  factory UserModel.fromJson(Map<String, dynamic> map) => UserModel(
    uid: map['uid'],
    name: map['name'],
    email: map['email'],
    isVerified: map['isVerified'],
  );

  factory UserModel.fromUserEntity(UserEntity user) => UserModel(
    uid: user.uid,
    name: user.name,
    email: user.email,
    isVerified: user.isVerified,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': ?name,
    'email': ?email,
    'isVerified': isVerified,
  };
}
