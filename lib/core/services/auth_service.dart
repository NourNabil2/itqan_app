// lib/services/auth_service.dart
import 'package:flutter/cupertino.dart';
import 'package:itqan_gym/data/models/app_user_model.dart';
import 'package:itqan_gym/data/models/subscription_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _subscriptionKey = 'cached_subscription';
  static const String _lastSyncKey = 'last_sync_time';

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // سيتم إرسال email verification تلقائياً
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Sync subscription after login
      if (response.user != null) {
        await syncSubscription(response.user!.id);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _clearLocalSubscription();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearSubscriptionCache() async {
    try {
      await _clearLocalSubscription();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subscriptionKey);
      debugPrint('🗑️ Subscription cache cleared');
    } catch (e) {
      debugPrint('⚠️ Failed to clear subscription cache: $e');
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      if (currentUser?.email == null) {
        throw Exception('No user logged in');
      }

      await _supabase.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }


  /// Delete user account and all associated data
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Call Supabase RPC function to delete all user data
      await _supabase.rpc('delete_user_account', params: {
        'user_id_param': userId,
      });

      // Sign out after successful deletion
      await signOut();

      debugPrint('✅ Account deleted successfully');
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      rethrow;
    }
  }

  // Get user subscription from Supabase
  Future<Subscription?> getSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      final subscription = Subscription.fromJson(response);

      // Cache in local storage
      await _cacheSubscription(subscription);

      return subscription;
    } catch (e) {
      // If network error, try to get from cache
      return await _getCachedSubscription();
    }
  }

  // Sync subscription (call after login or periodically)
  Future<Subscription?> syncSubscription(String userId) async {
    try {
      final subscription = await getSubscription(userId);
      await _updateLastSyncTime();
      return subscription;
    } catch (e) {
      return await _getCachedSubscription();
    }
  }

  // Get current user with subscription
  Future<AppUser?> getCurrentAppUser() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      // Try to sync subscription
      Subscription? subscription = await getSubscription(user.id);

      // If failed, try cache
      subscription ??= await _getCachedSubscription();

      return AppUser.fromSupabaseUser(user, subscription);
    } catch (e) {
      return null;
    }
  }

  // Check if subscription needs sync (call on app start if online)
  Future<bool> needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);

    if (lastSync == null) return true;

    final lastSyncTime = DateTime.parse(lastSync);
    final difference = DateTime.now().difference(lastSyncTime);

    // Sync if more than 1 hour
    return difference.inHours >= 1;
  }

  // Cache subscription in local storage
  Future<void> _cacheSubscription(Subscription subscription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _subscriptionKey,
      jsonEncode(subscription.toLocalStorage()),
    );
  }

  // Get cached subscription
  Future<Subscription?> _getCachedSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_subscriptionKey);

      if (cached == null) return null;

      return Subscription.fromLocalStorage(jsonDecode(cached));
    } catch (e) {
      return null;
    }
  }

  // Clear local subscription
  Future<void> _clearLocalSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_subscriptionKey);
    await prefs.remove(_lastSyncKey);
  }

  // Update last sync time
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // Listen to auth changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}