// lib/core/services/ad_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsService extends ChangeNotifier {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const String _premiumCacheKey = 'cached_premium_status';

  bool _initialized = false;
  bool _premium = false;
  bool _disposed = false;
  bool _premiumLoaded = false; // Flag للتأكد من التحميل

  // Banner state
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _isLoadingBanner = false;

  // Backoff
  DateTime? _lastBannerAttempt;
  int _bannerRetryCount = 0;

  // Expose banner to UI
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerLoaded;
  bool get isPremium => _premium;
  bool get isInitialized => _initialized && _premiumLoaded;
  bool get isBannerAdReady => _isBannerLoaded && _bannerAd != null && _bannerAd!.responseInfo != null;


  // ====== Init ======
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Load premium status from cache FIRST (synchronous-like)
      await _loadPremiumStatusFromCache();
      _premiumLoaded = true;

      debugPrint('📦 Premium loaded from cache: $_premium');

      // 2. Initialize AdMob
      final init = await MobileAds.instance.initialize();
      debugPrint('✅ AdMob initialized: ${init.adapterStatuses}');

      if (kDebugMode) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: const ['DA367CF62EC76FAC8E133642203A5444'],
          ),
        );
        debugPrint('✅ Test device set');
      }

      _initialized = true;

      // 3. Notify listeners immediately after loading cache
      notifyListeners();

      debugPrint('🎯 AdsService fully initialized | Premium: $_premium');
    } catch (e) {
      debugPrint('❌ Ads init error: $e');
      _premiumLoaded = true; // Mark as loaded even on error
      notifyListeners();
    }
  }

  Future<void> _loadPremiumStatusFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _premium = prefs.getBool(_premiumCacheKey) ?? false;
    } catch (e) {
      debugPrint('⚠️ Failed to load premium status: $e');
      _premium = false;
    }
  }

  // ====== Premium ======
  Future<void> setPremiumStatus(bool isPremium) async {
    if (_premium == isPremium) return;

    _premium = isPremium;

    // Save to cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumCacheKey, isPremium);
      debugPrint('💾 Premium status saved: $isPremium');
    } catch (e) {
      debugPrint('⚠️ Failed to save premium status: $e');
    }

    if (_premium) {
      disposeAllAds();
      debugPrint('🔒 Ads disabled (Premium)');
    }

    notifyListeners();
  }

  // ====== Public Banner API ======
  Future<void> loadBannerAd(
      BuildContext context, {
        bool force = false,
        bool ignoreBackoff = false,
        AdSize? overrideSize,
      }) async {
    // Don't load if premium or not initialized
    if (!_initialized || _premium || _disposed || !_premiumLoaded) {
      debugPrint('⏭️ Skipping banner: initialized=$_initialized, premium=$_premium, loaded=$_premiumLoaded');
      return;
    }

    if (!force) {
      if (_isBannerLoaded || _isLoadingBanner) return;
    } else {
      _isLoadingBanner = false;
      _isBannerLoaded = false;
      _bannerAd?.dispose();
      _bannerAd = null;
    }

    // Backoff
    final now = DateTime.now();
    if (!ignoreBackoff && _lastBannerAttempt != null) {
      final wait = Duration(seconds: min(60, 3 * (pow(2, _bannerRetryCount).toInt())));
      if (now.isBefore(_lastBannerAttempt!.add(wait))) {
        debugPrint('⏳ Banner backoff; try later');
        return;
      }
    }

    _isLoadingBanner = true;
    _lastBannerAttempt = DateTime.now();

    // Try adaptive first
    AdSize? adaptive;
    if (overrideSize == null) {
      try {
        final width = MediaQuery.of(context).size.width.truncate();
        adaptive = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      } catch (_) {}
    }

    final sizesToTry = <AdSize>[
      if (overrideSize != null) overrideSize else if (adaptive != null) adaptive,
      AdSize.largeBanner,
      AdSize.banner,
    ].whereType<AdSize>().toList();

    for (final size in sizesToTry) {
      final ok = await _loadWithSize(size);
      if (ok) return;
    }

    _isLoadingBanner = false;
    _isBannerLoaded = false;
    _bannerRetryCount = min(5, _bannerRetryCount + 1);
    notifyListeners();
  }

  Future<bool> _loadWithSize(AdSize size) async {
    final completer = Completer<bool>();

    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            if (!completer.isCompleted) completer.complete(false);
            return;
          }
          _bannerAd?.dispose();
          _bannerAd = ad as BannerAd;
          _isBannerLoaded = true;
          _isLoadingBanner = false;
          _bannerRetryCount = 0;

          debugPrint('✅ Banner loaded (${size.width}x${size.height})');
          notifyListeners();
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerLoaded = false;
          _isLoadingBanner = false;
          debugPrint('❌ Banner failed: ${error.code} - ${error.message}');
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    try {
      await ad.load();
    } catch (e) {
      debugPrint('❌ Banner load threw: $e');
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
    _isLoadingBanner = false;
    notifyListeners();
  }

  void disposeAllAds() {
    disposeBannerAd();
    _disposed = true;
    debugPrint('🗑️ All ads disposed');
  }

  String get _bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-9503585436307618/8891691652';
  }
}