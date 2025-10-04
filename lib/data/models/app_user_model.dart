// في app_user_model.dart
import 'package:itqan_gym/data/models/subscription_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final bool emailVerified;
  final DateTime createdAt;
  final Subscription? subscription;

  const AppUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.createdAt,
    this.subscription,
  });

  bool get isPremium => subscription?.isActive ?? false;

  AppUser copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    DateTime? createdAt,
    Subscription? subscription,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      subscription: subscription ?? this.subscription,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'email_verified': emailVerified,
      'created_at': createdAt.toIso8601String(),
      'subscription': subscription?.toJson(),
    };
  }

  factory AppUser.fromSupabaseUser(
      User user,
      Subscription? subscription,
      ) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      emailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt),
      subscription: subscription,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      emailVerified: json['email_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
    );
  }
}