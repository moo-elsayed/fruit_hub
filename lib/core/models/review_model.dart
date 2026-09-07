import 'package:fruit_hub/core/entities/review_entity.dart';

class ReviewModel {
  const ReviewModel({
    required this.name,
    required this.image,
    required this.description,
    required this.date,
    required this.rating,
    this.userId = '',
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    date: json['date'] as String? ?? '',
    image: json['image'] as String? ?? '',
    userId: json['userId'] as String? ?? json['uId'] as String? ?? '',
  );

  factory ReviewModel.fromEntity(ReviewEntity reviewEntity) => ReviewModel(
    name: reviewEntity.name,
    description: reviewEntity.description,
    rating: reviewEntity.rating,
    date: reviewEntity.date,
    image: reviewEntity.image,
    userId: reviewEntity.userId,
  );

  final String name;
  final String image;
  final String description;
  final String date;
  final double rating;
  final String userId;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'rating': rating,
    'date': date,
    'image': image,
    if (userId.isNotEmpty) 'userId': userId,
  };

  ReviewEntity toEntity() => ReviewEntity(
    name: name,
    description: description,
    rating: rating,
    date: date,
    image: image,
    userId: userId,
  );
}
