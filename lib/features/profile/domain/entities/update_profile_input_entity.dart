import 'package:equatable/equatable.dart';

class UpdateProfileInputEntity extends Equatable {
  const UpdateProfileInputEntity({
    required this.uid,
    required this.name,
    required this.phone,
    required this.image,
  });

  final String uid;
  final String name;
  final String phone;
  final String image;

  @override
  List<Object?> get props => [uid, name, phone, image];
}
