// lib/core/widgets/ads_widgets/banner_ad_widget.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _ad;
  bool _loading = false;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ابدأ التحميل أول ما يبقى عندنا MediaQuery
    if (!_loading && _ad == null) {
      _load();
    }
  }

  Future<void> _load() async {
    _loading = true;

    AdSize? adaptive;
    try {
      final width = MediaQuery.of(context).size.width.truncate();
      adaptive = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    } catch (_) {}

    final sizesToTry = <AdSize>[
      if (adaptive != null) adaptive,
      AdSize.fullBanner,     // 468x60
      AdSize.leaderboard,    // 728x90
      AdSize.largeBanner,    // 320x100
      AdSize.banner,         // 320x50
    ];

    for (final size in sizesToTry) {
      final ad = BannerAd(
        adUnitId: _bannerUnitId,
        size: size,
        request: const AdRequest(
          // لو عايزها NPA: nonPersonalizedAds: true,
        ),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            // تخلص من إعلان قديم لو موجود
            _ad?.dispose();
            _ad = ad as BannerAd;
            setState(() {
              _ready = true;
              _loading = false;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            // جرّب الحجم اللي بعده
          },
        ),
      );

      try {
        await ad.load();
        if (_ready) return; // اتحمّل خلاص
      } catch (_) {
        ad.dispose();
      }
    }

    // لو كل المحاولات فشلت
    if (mounted) {
      setState(() {
        _loading = false;
        _ready = false;
      });
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    _ad = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_ready || _ad == null) {
      // Placeholder صغير يمنع القفز
      return SizedBox(height: AdSize.banner.height.toDouble());
    }
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }

  String get _bannerUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Banner
    }
    return 'ca-app-pub-9503585436307618/8891691652'; // Prod Banner
  }
}
