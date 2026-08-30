import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';

class PaginatedProductsEntity extends Equatable {
  const PaginatedProductsEntity({
    required this.fruits,
    this.lastDoc,
    required this.hasMore,
  });

  final List<FruitEntity> fruits;
  final dynamic lastDoc;
  final bool hasMore;

  @override
  List<Object?> get props => [fruits, lastDoc, hasMore];
}
