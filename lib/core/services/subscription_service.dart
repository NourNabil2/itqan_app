// lib/services/subscription_service.dart
import 'package:itqan_gym/data/models/subscription_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SubscriptionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create or update subscription (للاستخدام من Admin panel أو بعد الدفع)
  Future<Subscription> createOrUpdateSubscription({
    required String userId,
    required String subscriptionType, // 'monthly' or 'lifetime'
  }) async {
    try {
      final now = DateTime.now();
      DateTime? expiredDate;

      if (subscriptionType == 'monthly') {
        // Add 30 days
        expiredDate = now.add(const Duration(days: 30));
      }

      final data = {
        'user_id': userId,
        'subscription_type': subscriptionType,
        'is_active': true,
        'start_date': now.toIso8601String(),
        'expired_date': expiredDate?.toIso8601String(),
      };

      // Upsert (insert or update if exists)
      final response = await _supabase
          .from('subscriptions')
          .upsert(data)
          .select()
          .single();

      return Subscription.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Renew monthly subscription
  Future<Subscription> renewMonthlySubscription(String userId) async {
    try {
      final now = DateTime.now();
      final expiredDate = now.add(const Duration(days: 30));

      final response = await _supabase
          .from('subscriptions')
          .update({
        'start_date': now.toIso8601String(),
        'expired_date': expiredDate.toIso8601String(),
        'is_active': true,
      })
          .eq('user_id', userId)
          .select()
          .single();

      return Subscription.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription(String userId) async {
    try {
      await _supabase
          .from('subscriptions')
          .update({'is_active': false})
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Check and update expired subscriptions (call periodically)
  Future<void> checkAndUpdateExpiredSubscriptions() async {
    try {
      await _supabase.rpc('update_expired_subscriptions');
    } catch (e) {
      // Create this function in Supabase:
      // CREATE OR REPLACE FUNCTION update_expired_subscriptions()
      // RETURNS void AS $$
      // BEGIN
      //   UPDATE subscriptions
      //   SET is_active = false
      //   WHERE subscription_type = 'monthly'
      //     AND expired_date < NOW()
      //     AND is_active = true;
      // END;
      // $$ LANGUAGE plpgsql;
    }
  }
}