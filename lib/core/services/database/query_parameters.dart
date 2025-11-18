import 'package:equatable/equatable.dart';

class QueryParameters extends Equatable {
  const QueryParameters({
    this.searchQuery,
    this.orderBy,
    this.descending = false,
    this.limit,
    this.whereInIds,
  });

  final String? orderBy;
  final String? searchQuery;
  final bool descending;
  final int? limit;
  final List<String>? whereInIds;

  @override
  List<Object?> get props => [
    orderBy,
    searchQuery,
    descending,
    limit,
    whereInIds,
  ];
}
