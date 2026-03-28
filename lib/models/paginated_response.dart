class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalDocs;
  final bool hasPrevPage;
  final bool hasNextPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalDocs,
    required this.hasPrevPage,
    required this.hasNextPage,
  });

  factory PaginationMeta.fromJson(
    Map<String, dynamic>? json, {
    required int fallbackPage,
    required int fallbackLimit,
    required int fallbackItemCount,
  }) {
    if (json == null) {
      final inferredHasNext = fallbackItemCount >= fallbackLimit;
      return PaginationMeta(
        currentPage: fallbackPage,
        totalPages: inferredHasNext ? fallbackPage + 1 : fallbackPage,
        totalDocs: (fallbackPage - 1) * fallbackLimit + fallbackItemCount,
        hasPrevPage: fallbackPage > 1,
        hasNextPage: inferredHasNext,
      );
    }

    final currentPage = (json['currentPage'] as num?)?.toInt() ?? fallbackPage;
    final totalPages = (json['totalPages'] as num?)?.toInt() ?? currentPage;
    final totalDocs = (json['totalDocs'] as num?)?.toInt() ?? fallbackItemCount;

    return PaginationMeta(
      currentPage: currentPage,
      totalPages: totalPages,
      totalDocs: totalDocs,
      hasPrevPage: json['hasPrevPage'] == true || currentPage > 1,
      hasNextPage: json['hasNextPage'] == true || currentPage < totalPages,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta pagination;

  const PaginatedResponse({
    required this.items,
    required this.pagination,
  });
}
