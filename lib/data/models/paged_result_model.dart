// Model này khớp với PagedResultDTO<T> của C#
// Nó là một model "chung" (generic), bạn có thể dùng lại cho Users, Classes, v.v.

class PagedResultModel<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PagedResultModel({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  // Một hàm 'fromJson' generic
  factory PagedResultModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    // Lấy danh sách 'items' từ JSON
    final itemsList =
        (json['items'] as List? ?? [])
            .map((itemJson) => fromJsonT(itemJson as Map<String, dynamic>))
            .toList();

    return PagedResultModel<T>(
      items: itemsList,
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}
