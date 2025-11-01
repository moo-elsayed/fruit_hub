class QueryParameters {
  const QueryParameters({
    this.searchQuery,
    this.orderBy,
    this.descending = false,
    this.limit,
  });

  final String? orderBy;
  final String? searchQuery;
  final bool descending;
  final int? limit;
}
