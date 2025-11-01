class ReviewEntity {
  ReviewEntity({
    this.name = '',
    this.image = '',
    this.description = '',
    this.date = '',
    this.rating = 0,
  });

  final String name;
  final String image;
  final String description;
  final String date;
  final double rating;
}
