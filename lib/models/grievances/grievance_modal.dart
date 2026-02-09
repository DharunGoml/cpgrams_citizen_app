abstract class GrievanceModalPayload {
  Map<String, dynamic> toJson();
}

class GrievanceListModal extends GrievanceModalPayload {
  final String? status;
  final String deskId;
  final bool? isHierarchical;
  final String? entityId;
  final String? categoryId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? page;
  final int? size;
  final String? sortColumn;
  final int? sortDirection;

  GrievanceListModal({
    this.status,
    required this.deskId,
    this.isHierarchical,
    this.entityId,
    this.categoryId,
    this.fromDate,
    this.toDate,
    this.page = 0,
    this.size = 10,
    this.sortColumn,
    this.sortDirection,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'deskId': deskId,
      if (status != null) 'status': status,
      if (isHierarchical != null) 'isHierarchical': isHierarchical,
      if (entityId != null) 'entityId': entityId,
      if (categoryId != null) 'categoryId': categoryId,
      if (fromDate != null) 'fromDate': fromDate!.toIso8601String(),
      if (toDate != null) 'toDate': toDate!.toIso8601String(),
      'page': page,
      'size': size,
      if (sortColumn != null) 'sortColumn': sortColumn,
      if (sortDirection != null) 'sortDirection': sortDirection,
    };
  }
}
