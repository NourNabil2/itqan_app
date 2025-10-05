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
  bool _premiumLoaded = false;

  // ====================== Banner ======================
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _isLoadingBanner = false;
  DateTime? _lastBannerAttempt;
  int _bannerRetryCount = 0;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerLoaded;
  bool get isBannerAdReady =>
      _isBannerLoaded && _bannerAd != null && _bannerAd!.responseInfo != null;

  // ================== Interstitial (General) ==================
  InterstitialAd? _interstitialGeneral;
  bool _isLoadingInterstitialGeneral = false;
  int _interstitialRetryGeneral = 0;
  DateTime? _lastInterstitialShownGeneral;
  int _interstitialShownCountGeneral = 0;

  // ================== Interstitial (Team Card) ==================
  InterstitialAd? _interstitialTeam;
  bool _isLoadingInterstitialTeam = false;
  int _interstitialRetryTeam = 0;
  DateTime? _lastInterstitialShownTeam;
  int _interstitialShownCountTeam = 0;

  // ================== Policies / Caps ==================
  // تحكم عام للنوعين (تقدر تعمل لكل نوع إعدادات مستقلة لو حابب)
  Duration interstitialCooldown = const Duration(minutes: 2);
  int interstitialMaxPerSession = 6;

  // ================== Exposed State ==================
  bool get isPremium => _premium;
  bool get isInitialized => _initialized && _premiumLoaded;

  bool get isGeneralInterstitialReady =>
      _interstitialGeneral != null && !_isLoadingInterstitialGeneral;

  bool get isTeamInterstitialReady =>
      _interstitialTeam != null && !_isLoadingInterstitialTeam;

  // ================== Initialize ==================
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _loadPremiumStatusFromCache();
      _premiumLoaded = true;
      debugPrint('📦 Premium loaded from cache: $_premium');

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
      notifyListeners();

      // اختياري: تحميل مسبق للـ interstitials
      unawaited(preloadInterstitial());
      unawaited(preloadInterstitialTeamCard());

      debugPrint('🎯 AdsService fully initialized | Premium: $_premium');
    } catch (e) {
      debugPrint('❌ Ads init error: $e');
      _premiumLoaded = true; // حتى لو في خطأ نكمّل الحالة
      notifyListeners();
    }
  }

  // ================== Premium ==================
  Future<void> setPremiumStatus(bool isPremium) async {
    if (_premium == isPremium) return;

    _premium = isPremium;
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

  Future<void> _loadPremiumStatusFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _premium = prefs.getBool(_premiumCacheKey) ?? false;
    } catch (e) {
      debugPrint('⚠️ Failed to load premium status: $e');
      _premium = false;
    }
  }

  // ================== Banner API ==================
  Future<void> loadBannerAd(
      BuildContext context, {
        bool force = false,
        bool ignoreBackoff = false,
        AdSize? overrideSize,
      }) async {
    if (!_initialized || _premium || _disposed || !_premiumLoaded) {
      debugPrint(
          '⏭️ Skipping banner: initialized=$_initialized, premium=$_premium, loaded=$_premiumLoaded');
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

    final now = DateTime.now();
    if (!ignoreBackoff && _lastBannerAttempt != null) {
      final wait = Duration(
          seconds: min(60, 3 * (pow(2, _bannerRetryCount).toInt())));
      if (now.isBefore(_lastBannerAttempt!.add(wait))) {
        debugPrint('⏳ Banner backoff; try later');
        return;
      }
    }

    _isLoadingBanner = true;
    _lastBannerAttempt = DateTime.now();

    AdSize? adaptive;
    if (overrideSize == null) {
      try {
        final width = MediaQuery.of(context).size.width.truncate();
        adaptive =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            width);
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


  // ================== Interstitial (General) ==================
  Future<void> preloadInterstitial({bool force = false}) async {
    if (!_initialized || _premium || _disposed) return;
    if (!force && (_interstitialGeneral != null || _isLoadingInterstitialGeneral)) return;

    _isLoadingInterstitialGeneral = true;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            _isLoadingInterstitialGeneral = false;
            return;
          }
          _interstitialGeneral = ad;
          _isLoadingInterstitialGeneral = false;
          _interstitialRetryGeneral = 0;
          debugPrint('✅ Interstitial (general) loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitialGeneral = false;
          _interstitialGeneral = null;
          _interstitialRetryGeneral = min(5, _interstitialRetryGeneral + 1);
          debugPrint(
              '❌ Interstitial (general) failed: ${error.code} - ${error.message}');
          final delay =
          Duration(seconds: 2 * pow(2, _interstitialRetryGeneral).toInt());
          Future.delayed(delay, () {
            if (!_disposed && !_premium) {
              preloadInterstitial();
            }
          });
        },
      ),
    );
  }

  Future<bool> showInterstitial({
    VoidCallback? onDismissed,
    bool ignoreCooldown = false,
  }) async {
    if (!_initialized || _premium || _disposed) return false;

    if (!ignoreCooldown) {
      if (_lastInterstitialShownGeneral != null &&
          DateTime.now().difference(_lastInterstitialShownGeneral!) <
              interstitialCooldown) {
        debugPrint('⏳ Interstitial (general) cooldown active');
        return false;
      }
      if (_interstitialShownCountGeneral >= interstitialMaxPerSession) {
        debugPrint('🚦 Interstitial (general) session cap reached');
        return false;
      }
    }

    final ad = _interstitialGeneral;
    if (ad == null) {
      debugPrint('ℹ️ Interstitial (general) not ready, preloading…');
      preloadInterstitial();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShownGeneral = DateTime.now();
        _interstitialShownCountGeneral += 1;
        debugPrint('🟦 Interstitial (general) shown (#$_interstitialShownCountGeneral)');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialGeneral = null;
        onDismissed?.call();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            '❌ Interstitial (general) show failed: ${error.code} - ${error.message}');
        ad.dispose();
        _interstitialGeneral = null;
        onDismissed?.call();
        preloadInterstitial();
      },
    );

    try {
      await ad.show();
      _interstitialGeneral = null;
      return true;
    } catch (e) {
      debugPrint('❌ Interstitial (general) show threw: $e');
      _interstitialGeneral?.dispose();
      _interstitialGeneral = null;
      preloadInterstitial();
      return false;
    }
  }

  // ================== Interstitial (Team Card) ==================
  Future<void> preloadInterstitialTeamCard({bool force = false}) async {
    if (!_initialized || _premium || _disposed) return;
    if (!force && (_interstitialTeam != null || _isLoadingInterstitialTeam)) return;

    _isLoadingInterstitialTeam = true;

    await InterstitialAd.load(
      adUnitId: _interstitialTeamCardAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            _isLoadingInterstitialTeam = false;
            return;
          }
          _interstitialTeam = ad;
          _isLoadingInterstitialTeam = false;
          _interstitialRetryTeam = 0;
          debugPrint('✅ Interstitial (team) loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitialTeam = false;
          _interstitialTeam = null;
          _interstitialRetryTeam = min(5, _interstitialRetryTeam + 1);
          debugPrint(
              '❌ Interstitial (team) failed: ${error.code} - ${error.message}');
          final delay =
          Duration(seconds: 2 * pow(2, _interstitialRetryTeam).toInt());
          Future.delayed(delay, () {
            if (!_disposed && !_premium) {
              preloadInterstitialTeamCard();
            }
          });
        },
      ),
    );
  }

  Future<bool> showTeamCardInterstitial({
    VoidCallback? onDismissed,
    bool ignoreCooldown = false,
  }) async {
    if (!_initialized || _premium || _disposed) return false;

    if (!ignoreCooldown) {
      if (_lastInterstitialShownTeam != null &&
          DateTime.now().difference(_lastInterstitialShownTeam!) <
              interstitialCooldown) {
        debugPrint('⏳ Interstitial (team) cooldown active');
        return false;
      }
      if (_interstitialShownCountTeam >= interstitialMaxPerSession) {
        debugPrint('🚦 Interstitial (team) session cap reached');
        return false;
      }
    }

    final ad = _interstitialTeam;
    if (ad == null) {
      debugPrint('ℹ️ Interstitial (team) not ready, preloading…');
      preloadInterstitialTeamCard();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShownTeam = DateTime.now();
        _interstitialShownCountTeam += 1;
        debugPrint('🟩 Interstitial (team) shown (#$_interstitialShownCountTeam)');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialTeam = null;
        onDismissed?.call();
        preloadInterstitialTeamCard();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            '❌ Interstitial (team) show failed: ${error.code} - ${error.message}');
        ad.dispose();
        _interstitialTeam = null;
        onDismissed?.call();
        preloadInterstitialTeamCard();
      },
    );

    try {
      await ad.show();
      _interstitialTeam = null;
      return true;
    } catch (e) {
      debugPrint('❌ Interstitial (team) show threw: $e');
      _interstitialTeam?.dispose();
      _interstitialTeam = null;
      preloadInterstitialTeamCard();
      return false;
    }
  }

  // ================== Dispose ==================
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
    _isLoadingBanner = false;
    notifyListeners();
  }

  void disposeAllAds() {
    disposeBannerAd();
    _interstitialGeneral?.dispose();
    _interstitialGeneral = null;
    _interstitialTeam?.dispose();
    _interstitialTeam = null;
    _disposed = true;
    debugPrint('🗑️ All ads disposed');
  }

  // ================== Ad Unit IDs ==================
  String get _bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Banner
    }
    return 'ca-app-pub-9503585436307618/8891691652'; // Prod Banner
  }

  String get _interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial
    }
    return 'ca-app-pub-9503585436307618/4127833021'; // Prod General
  }

  String get _interstitialTeamCardAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial
    }
    return 'ca-app-pub-9503585436307618/9067774256'; // Prod Team Card
  }
}
