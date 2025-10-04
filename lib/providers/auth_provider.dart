// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:itqan_gym/core/services/ad_service.dart';
import 'package:itqan_gym/core/services/auth_service.dart';
import 'package:itqan_gym/core/services/time_validation_service.dart';
import 'package:itqan_gym/data/models/app_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  // Keys for caching
  static const String _userCacheKey = 'cached_user';
  static const String _lastSyncKey = 'last_subscription_sync';
  static const String _premiumCacheKey = 'cached_premium_status';
  static const String _expiryDateKey = 'cached_expiry_date';

  // Services
  final AuthService _authService = AuthService();
  final TimeValidationService _timeValidation = TimeValidationService();

  // State
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isTimeValid = true;
  bool _isInitialized = false;

  // Timers
  Timer? _timeValidationTimer;
  Timer? _subscriptionSyncTimer;

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isPremium => _currentUser?.isPremium ?? false;
  bool get isTimeValid => _isTimeValid;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initialize();
  }

  // ==================== Initialization ====================

  Future<void> _initialize() async {
    try {
      // 1. Load from cache first (synchronous, fast)
      await _loadFromCache();

      // Mark as initialized immediately with cached data
      _isInitialized = true;
      notifyListeners();

      // 2. Then load from server (asynchronous, in background)
      await _loadCurrentUser();

      // 3. Setup timers
      _setupTimers();

      debugPrint('🚀 AuthProvider initialized');
    } catch (e) {
      debugPrint('❌ AuthProvider initialization failed: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }


// في auth_provider.dart
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cachedUserJson = prefs.getString(_userCacheKey);
      if (cachedUserJson != null) {
        final userMap = jsonDecode(cachedUserJson) as Map<String, dynamic>;
        _currentUser = AppUser.fromJson(userMap);

        final isPremiumCached = prefs.getBool(_premiumCacheKey) ?? false;
        final expiryDateStr = prefs.getString(_expiryDateKey);

        if (isPremiumCached && expiryDateStr != null) {
          final expiryDate = DateTime.parse(expiryDateStr);
          final isValid = await _timeValidation.isSubscriptionValid(expiryDate);

          if (!isValid) {
            // Subscription expired
            debugPrint('⚠️ Subscription expired - clearing cache');

            // 1. Update premium cache
            await _updatePremiumCache(false, null);

            // 2. Update user object
            _currentUser = _currentUser?.copyWith(
              subscription: _currentUser?.subscription?.copyWith(isActive: false),
            );

            // 3. Clear subscription from AuthService cache
            await _authService.clearSubscriptionCache();

            // 4. Update AdsService
            await AdsService.instance.setPremiumStatus(false);

            // 5. Save updated user to cache
            await _saveToCache();
          }
        }

        // Update AdsService with current status
        await AdsService.instance.setPremiumStatus(isPremium);

        debugPrint('📦 Loaded from cache | Premium: $isPremium');
      }
    } catch (e) {
      debugPrint('⚠️ Cache load error: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentUser != null) {
        // Save user data
        final userJson = jsonEncode(_currentUser!.toJson());
        await prefs.setString(_userCacheKey, userJson);

        // Save premium status
        await _updatePremiumCache(
          isPremium,
          _currentUser?.subscription?.expiredDate,
        );

        // Save last sync time
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        debugPrint('💾 Saved to cache');
      } else {
        // Clear cache on logout
        await _clearCache();
      }
    } catch (e) {
      debugPrint('⚠️ Cache save error: $e');
    }
  }

  Future<void> _updatePremiumCache(bool isPremium, DateTime? expiryDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumCacheKey, isPremium);

    if (expiryDate != null) {
      await prefs.setString(_expiryDateKey, expiryDate.toIso8601String());
    } else {
      await prefs.remove(_expiryDateKey);
    }
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
    await prefs.remove(_premiumCacheKey);
    await prefs.remove(_expiryDateKey);
    await prefs.remove(_lastSyncKey);
  }

  void _setupTimers() {
    // Time validation every 5 minutes
    _timeValidationTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) => _validateTime(),
    );

    // Subscription sync every 30 minutes
    _subscriptionSyncTimer = Timer.periodic(
      const Duration(minutes: 30),
          (_) => syncSubscription(silent: true),
    );
  }

  @override
  void dispose() {
    _timeValidationTimer?.cancel();
    _subscriptionSyncTimer?.cancel();
    super.dispose();
  }

  // ==================== User Management ====================

  Future<void> _loadCurrentUser() async {
    try {
      _setLoading(true);

      final session = _authService.currentUser;

      if (session != null) {
        _currentUser = await _authService.getCurrentAppUser();

        if (_currentUser != null) {
          await _onUserLoaded();
          await _saveToCache(); // Save to cache after loading
          debugPrint('✅ User: ${_currentUser!.email} | Premium: ${_currentUser!.isPremium}');
        }
      } else {
        await _clearCache();
        debugPrint('ℹ️ No active session');
      }
    } catch (e) {
      debugPrint('❌ Load user error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _onUserLoaded() async {
    // Validate time for premium users
    if (_currentUser?.subscription != null) {
      await _validateTime();
    }

    // Update ad status
    AdsService.instance.setPremiumStatus(isPremium);

    // Dispose ads for premium users
    if (isPremium) {
      AdsService.instance.disposeAllAds();
    }
  }

  Future<void> refresh() async {
    await _loadCurrentUser();
  }

  // ==================== Authentication ====================

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signUp(email: email, password: password);

      debugPrint('✅ Sign up successful');
      return true;
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signIn(email: email, password: password);
      await _loadCurrentUser();

      debugPrint('✅ Sign in successful');
      return true;
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);

      await _authService.signOut();
      await _timeValidation.clearValidationData();
      await _clearCache();

      _currentUser = null;
      AdsService.instance.setPremiumStatus(false);
      AdsService.instance.disposeAllAds();

      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      _setError(_parseError(e));
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Email & Password ====================

  Future<bool> resendVerificationEmail() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resendVerificationEmail();

      debugPrint('✅ Verification email sent');
      return true;
    } catch (e) {
      debugPrint('❌ Resend verification error: $e');
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);

      debugPrint('✅ Password reset email sent');
      return true;
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Subscription ====================

  Future<void> syncSubscription({bool silent = false}) async {
    if (_currentUser == null) return;

    try {
      if (!silent) debugPrint('🔄 Syncing subscription...');

      final subscription = await _authService.syncSubscription(_currentUser!.id);

      if (subscription != null) {
        final wasPremium = _currentUser!.isPremium;

        _currentUser = AppUser(
          id: _currentUser!.id,
          email: _currentUser!.email,
          emailVerified: _currentUser!.emailVerified,
          createdAt: _currentUser!.createdAt,
          subscription: subscription,
        );

        // Save updated data to cache
        await _saveToCache();

        // Update ads if premium status changed
        if (wasPremium != _currentUser!.isPremium) {
          AdsService.instance.setPremiumStatus(_currentUser!.isPremium);

          if (_currentUser!.isPremium) {
            AdsService.instance.disposeAllAds();
          }
        }

        await _validateTime();
        notifyListeners();

        if (!silent) {
          debugPrint('✅ Subscription: ${subscription.subscriptionType} | Premium: ${_currentUser!.isPremium}');
        }
      }
    } catch (e) {
      if (!silent) debugPrint('❌ Subscription sync error: $e');
    }
  }

  Future<bool> isSubscriptionValid() async {
    if (_currentUser?.subscription?.expiredDate == null) {
      return _currentUser?.subscription?.subscriptionType == 'lifetime';
    }

    return await _timeValidation.isSubscriptionValid(
      _currentUser!.subscription!.expiredDate,
    );
  }

  // ==================== Time Validation ====================

  Future<void> _validateTime() async {
    if (_currentUser?.subscription == null) return;

    try {
      _isTimeValid = await _timeValidation.validateDeviceTime();

      if (!_isTimeValid) {
        _setError('تم اكتشاف تلاعب في وقت الجهاز. يرجى ضبط الوقت بشكل صحيح.');
        debugPrint('⚠️ Time manipulation detected');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Time validation error: $e');
    }
  }

  // ==================== State Management ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ==================== Error Parsing ====================

  String _parseError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (errorString.contains('email not confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولاً';
    }

    if (errorString.contains('user already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }

    if (errorString.contains('network')) {
      return 'خطأ في الاتصال بالإنترنت';
    }

    if (errorString.contains('timeout')) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    }

    return 'حدث خطأ: ${error.toString()}';
  }
}