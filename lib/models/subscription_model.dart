class SubscriptionModel {
  final String id;
  final String status;
  final String? productId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool willRenew;
  final String store;

  SubscriptionModel({
    required this.id,
    required this.status,
    this.productId,
    this.startDate,
    this.endDate,
    required this.willRenew,
    required this.store,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'inactive',
      productId: json['product_id'],
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      willRenew: json['will_renew'] ?? false,
      store: json['store'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'product_id': productId,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'will_renew': willRenew,
      'store': store,
    };
  }

  bool get isActive => status == 'active';
  bool get isExpired => endDate != null && endDate!.isBefore(DateTime.now());
  bool get isExpiringSoon {
    if (endDate == null) return false;
    final now = DateTime.now();
    final difference = endDate!.difference(now).inDays;
    return difference <= 7 && difference > 0;
  }

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, status: $status, productId: $productId, willRenew: $willRenew)';
  }
}
