import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    this.uid = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.isVerified = false,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isVerified;

  @override
  List<Object?> get props => [uid, name, email, phone, isVerified];

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    bool? isVerified,
  }) => UserEntity(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    isVerified: isVerified ?? this.isVerified,
  );
}
