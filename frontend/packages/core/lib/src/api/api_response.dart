/// Isi sukses `{success: true, data, meta}`.
class ApiResponse<T> {
  const ApiResponse({required this.data, this.meta = const {}});

  final T data;
  final Map<String, dynamic> meta;

  PaginationMeta? get pagination {
    final raw = meta['pagination'];
    return raw is Map<String, dynamic> ? PaginationMeta.fromJson(raw) : null;
  }
}

class PaginationMeta {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
        lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
        perPage: (json['per_page'] as num?)?.toInt() ?? 15,
        total: (json['total'] as num?)?.toInt() ?? 0,
      );

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}

/// Satu halaman data dari endpoint paginated.
class Paged<T> {
  const Paged({required this.items, required this.pagination});

  final List<T> items;
  final PaginationMeta pagination;
}
