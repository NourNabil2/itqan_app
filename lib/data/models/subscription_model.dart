// lib/data/models/subscription_model.dart
class Subscription {
  final String id;
  final String userId;
  final String subscriptionType;
  final bool isActive;
  final DateTime startDate;
  final DateTime? expiredDate;

  const Subscription({
    required this.id,
    required this.userId,
    required this.subscriptionType,
    required this.isActive,
    required this.startDate,
    this.expiredDate,
  });

  Subscription copyWith({
    String? id,
    String? userId,
    String? subscriptionType,
    bool? isActive,
    DateTime? startDate,
    DateTime? expiredDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      expiredDate: expiredDate ?? this.expiredDate,
    );
  }

  // For Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_type': subscriptionType,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'expired_date': expiredDate?.toIso8601String(),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      subscriptionType: json['subscription_type'],
      isActive: json['is_active'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      expiredDate: json['expired_date'] != null
          ? DateTime.parse(json['expired_date'])
          : null,
    );
  }

  // For local storage (SharedPreferences)
  Map<String, dynamic> toLocalStorage() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_type': subscriptionType,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'expired_date': expiredDate?.toIso8601String(),
    };
  }

  factory Subscription.fromLocalStorage(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      subscriptionType: json['subscription_type'],
      isActive: json['is_active'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      expiredDate: json['expired_date'] != null
          ? DateTime.parse(json['expired_date'])
          : null,
    );
  }
}