import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    this.uid = '',
    this.name = '',
    this.email = '',
    this.isVerified = false,
  });

  final String uid;
  final String name;
  final String email;
  final bool isVerified;

  @override
  List<Object?> get props => [uid, name, email, isVerified];

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    bool? isVerified,
  }) => UserEntity(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    email: email ?? this.email,
    isVerified: isVerified ?? this.isVerified,
  );
}
