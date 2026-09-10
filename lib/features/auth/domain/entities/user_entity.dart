import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    this.uid = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.image = '',
    this.isVerified = false,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String image;
  final bool isVerified;

  @override
  List<Object?> get props => [uid, name, email, phone, image, isVerified];

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? image,
    bool? isVerified,
  }) => UserEntity(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    image: image ?? this.image,
    isVerified: isVerified ?? this.isVerified,
  );
}
