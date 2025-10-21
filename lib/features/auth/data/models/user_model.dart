import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

class UserModel {
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isVerified,
  });

  final String uid;
  String name;
  final String email;
  final bool isVerified;

  factory UserModel.fromFirebaseUser(User user) => UserModel(
    uid: user.uid,
    name: user.displayName ?? '',
    email: user.email ?? '',
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
    name: user.name ?? '',
    email: user.email ?? '',
    isVerified: user.isVerified,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'isVerified': isVerified,
  };

  UserEntity toUserEntity() =>
      UserEntity(uid: uid, name: name, email: email, isVerified: isVerified);
}
