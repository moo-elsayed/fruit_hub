import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

class UserModel {
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isVerified,
  });

  factory UserModel.fromFirebaseUser(
    User user, {
    String? customName,
    Map<String, dynamic>? additionalProfile,
  }) {
    String resolvedName = (customName ?? user.displayName ?? '').trim();

    if (resolvedName.isEmpty) {
      for (final profile in user.providerData) {
        if (profile.displayName != null &&
            profile.displayName!.trim().isNotEmpty) {
          resolvedName = profile.displayName!.trim();
          break;
        }
      }
    }

    if (resolvedName.isEmpty && additionalProfile != null) {
      final profileName =
          additionalProfile['name'] ??
          additionalProfile['displayName'] ??
          additionalProfile['given_name'];
      if (profileName != null && profileName.toString().trim().isNotEmpty) {
        resolvedName = profileName.toString().trim();
      }
    }

    if (resolvedName.isEmpty && user.email != null && user.email!.contains('@')) {
      final emailPrefix = user.email!.split('@').first.trim();
      if (emailPrefix.isNotEmpty) {
        resolvedName = emailPrefix;
      }
    }

    return UserModel(
      uid: user.uid,
      name: resolvedName,
      email: user.email ?? '',
      isVerified: user.emailVerified,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    isVerified: map['isVerified'] ?? false,
  );

  factory UserModel.fromUserEntity(UserEntity user) => UserModel(
    uid: user.uid,
    name: user.name,
    email: user.email,
    isVerified: user.isVerified,
  );

  final String uid;
  String name;
  final String email;
  final bool isVerified;

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'isVerified': isVerified,
  };

  UserEntity toUserEntity() =>
      UserEntity(uid: uid, name: name, email: email, isVerified: isVerified);
}
