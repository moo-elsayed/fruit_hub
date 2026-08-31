import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/models/review_model.dart';

class FruitModel {
  FruitModel({
    required this.sellingCount,
    required this.reviews,
    required this.avgRating,
    required this.ratingCount,
    required this.isOrganic,
    required this.daysUntilExpiration,
    required this.weightInGrams,
    required this.numberOfCalories,
    required this.imagePath,
    required this.code,
    required this.isFeatured,
    required this.description,
    required this.price,
    required this.name,
  });

  factory FruitModel.fromJson(Map<String, dynamic> json) => FruitModel(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imagePath: json['imagePath'] ?? '',
    code: json['code'] ?? '',
    isFeatured: json['isFeatured'] as bool? ?? false,
    avgRating: (json['avgRating'] as num?) ?? 0,
    ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    isOrganic: json['isOrganic'] as bool? ?? false,
    daysUntilExpiration: (json['daysUntilExpiration'] as num?)?.toInt() ?? 0,
    weightInGrams:
        ((json['weightInGrams'] ?? json['unitAmount']) as num?)?.toInt() ?? 0,
    numberOfCalories: (json['numberOfCalories'] as num?)?.toInt() ?? 0,
    reviews: (json['reviews'] as List<dynamic>? ?? [])
        .map<ReviewModel>((reviewJson) => ReviewModel.fromJson(reviewJson))
        .toList(),
    sellingCount: (json['sellingCount'] as num?)?.toInt() ?? 0,
  );

  final String imagePath;
  final String name;
  final String code;
  final String description;
  final double price;
  final bool isFeatured;
  final bool isOrganic;
  final int daysUntilExpiration;
  final int numberOfCalories;
  final int weightInGrams;
  final int ratingCount;
  final int sellingCount;
  final num avgRating;
  final List<ReviewModel> reviews;

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
    daysUntilExpiration: daysUntilExpiration,
    weightInGrams: weightInGrams,
    numberOfCalories: numberOfCalories,
    reviews: reviews.map((review) => review.toEntity()).toList(),
  );
}
