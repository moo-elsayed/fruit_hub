import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';

class FruitEntity extends Equatable {
  const FruitEntity({
    this.imagePath = '',
    this.name = '',
    this.code = '',
    this.description = '',
    this.price = 0,
    this.isFeatured = false,
    this.isOrganic = false,
    this.daysUntilExpiration = 0,
    this.numberOfCalories = 0,
    this.weightInGrams = 0,
    this.ratingCount = 0,
    this.avgRating = 0,
    this.reviews = const [],
  });

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
  final num avgRating;
  final List<ReviewEntity> reviews;

  FruitEntity copyWith({
    String? imagePath,
    String? name,
    String? code,
    String? description,
    double? price,
    bool? isFeatured,
    bool? isOrganic,
    int? daysUntilExpiration,
    int? numberOfCalories,
    int? weightInGrams,
    int? ratingCount,
    num? avgRating,
    List<ReviewEntity>? reviews,
  }) => FruitEntity(
    imagePath: imagePath ?? this.imagePath,
    name: name ?? this.name,
    code: code ?? this.code,
    description: description ?? this.description,
    price: price ?? this.price,
    isFeatured: isFeatured ?? this.isFeatured,
    isOrganic: isOrganic ?? this.isOrganic,
    daysUntilExpiration: daysUntilExpiration ?? this.daysUntilExpiration,
    numberOfCalories: numberOfCalories ?? this.numberOfCalories,
    weightInGrams: weightInGrams ?? this.weightInGrams,
    ratingCount: ratingCount ?? this.ratingCount,
    avgRating: avgRating ?? this.avgRating,
    reviews: reviews ?? this.reviews,
  );

  @override
  List<Object?> get props => [
    imagePath,
    name,
    code,
    description,
    price,
    isFeatured,
    isOrganic,
    daysUntilExpiration,
    numberOfCalories,
    weightInGrams,
    ratingCount,
    avgRating,
    reviews,
  ];
}
