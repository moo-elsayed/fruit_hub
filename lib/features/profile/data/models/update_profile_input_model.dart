import '../../domain/entities/update_profile_input_entity.dart';

class UpdateProfileInputModel {
  const UpdateProfileInputModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.image,
  });

  factory UpdateProfileInputModel.fromEntity(UpdateProfileInputEntity entity) =>
      UpdateProfileInputModel(
        uid: entity.uid,
        name: entity.name,
        phone: entity.phone,
        image: entity.image,
      );

  factory UpdateProfileInputModel.fromJson(Map<String, dynamic> json) =>
      UpdateProfileInputModel(
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        image: json['image'] ?? '',
      );

  final String uid;
  final String name;
  final String phone;
  final String image;

  UpdateProfileInputModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? image,
  }) => UpdateProfileInputModel(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    image: image ?? this.image,
  );

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'phone': phone.trim(),
    'image': image.trim(),
  };

  UpdateProfileInputEntity toEntity() => UpdateProfileInputEntity(
    uid: uid,
    name: name,
    phone: phone,
    image: image,
  );
}
