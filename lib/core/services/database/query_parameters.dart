class QueryParameters {
  const QueryParameters({this.orderBy, this.descending = false, this.limit});

  final String? orderBy;
  final bool descending;
  final int? limit;
}
