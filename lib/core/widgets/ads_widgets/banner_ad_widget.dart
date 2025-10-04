// lib/core/widgets/banner_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:itqan_gym/core/services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  final _ads = AdsService.instance;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    _ads.addListener(_onAdsChange);
    // حمّل مرة واحدة بعد أول frame (ما تعيدش التحميل مع كل build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_requested) {
        _requested = true;
        _ads.loadBannerAd(context); // لا تستخدم force/ignoreBackoff هنا
      }
    });
  }

  void _onAdsChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ads.removeListener(_onAdsChange);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final ad = _ads.bannerAd;

    if (_ads.isBannerAdLoaded && ad != null) {
      return SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      );
    }

    return SizedBox(height: AdSize.banner.height.toDouble());
  }
}
