import '../../core/entities/review_entity.dart';

class ReviewModel {
  ReviewModel({
    required this.name,
    required this.image,
    required this.description,
    required this.date,
    required this.rating,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
      name: json['name'],
      description: json['description'],
      rating: json['rating'],
      date: json['date'],
      image: json['image'],
    );

  factory ReviewModel.fromEntity(ReviewEntity reviewEntity) => ReviewModel(
    name: reviewEntity.name,
    description: reviewEntity.description,
    rating: reviewEntity.rating,
    date: reviewEntity.date,
    image: reviewEntity.image,
  );

  final String name;
  final String image;
  final String description;
  final String date;
  final double rating;

  Map<String, dynamic> toJson() => {
      'name': name,
      'description': description,
      'rating': rating,
      'date': date,
      'image': image,
    };

  ReviewEntity toEntity() => ReviewEntity(
    name: name,
    description: description,
    rating: rating,
    date: date,
    image: image,
  );
}
