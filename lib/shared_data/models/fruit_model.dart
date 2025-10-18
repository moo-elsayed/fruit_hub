import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/shared_data/models/review_model.dart';

class FruitModel {
  FruitModel({
    required this.sellingCount,
    required this.reviews,
    required this.avgRating,
    required this.ratingCount,
    required this.isOrganic,
    required this.monthsUntilExpiration,
    required this.unitAmount,
    required this.numberOfCalories,
    required this.imagePath,
    required this.code,
    required this.isFeatured,
    required this.description,
    required this.price,
    required this.name,
  });

  final String imagePath;
  final String name;
  final String code;
  final String description;
  final double price;
  final bool isFeatured;
  final bool isOrganic;
  final int monthsUntilExpiration;
  final int numberOfCalories;
  final int unitAmount;
  final int ratingCount;
  final int sellingCount;
  final num avgRating;
  final List<ReviewModel> reviews;

  factory FruitModel.fromJson(Map<String, dynamic> json) => FruitModel(
    name: json['name'],
    description: json['description'],
    price: json['price'],
    imagePath: json['imagePath'],
    code: json['code'],
    isFeatured: json['isFeatured'],
    avgRating: json['avgRating'],
    ratingCount: json['ratingCount'],
    isOrganic: json['isOrganic'],
    monthsUntilExpiration: json['monthsUntilExpiration'],
    unitAmount: json['unitAmount'],
    numberOfCalories: json['numberOfCalories'],
    reviews: json['reviews']
        .map<ReviewModel>((reviewJson) => ReviewModel.fromJson(reviewJson))
        .toList(),
    sellingCount: json['sellingCount'],
  );

  FruitEntity toEntity() => FruitEntity(
    name: name,
    description: description,
    price: price,
    imagePath: imagePath,
    code: code,
    isFeatured: isFeatured,
    avgRating: avgRating,
    ratingCount: ratingCount,
    isOrganic: isOrganic,
    monthsUntilExpiration: monthsUntilExpiration,
    unitAmount: unitAmount,
    numberOfCalories: numberOfCalories,
    reviews: reviews.map((review) => review.toEntity()).toList(),
  );
}
