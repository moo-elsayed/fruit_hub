import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    this.name = '',
    this.image = '',
    this.description = '',
    this.date = '',
    this.rating = 0,
    this.userId = '',
  });

  final String name;
  final String image;
  final String description;
  final String date;
  final double rating;
  final String userId;

  @override
  List<Object?> get props => [name, image, description, date, rating, userId];
}
