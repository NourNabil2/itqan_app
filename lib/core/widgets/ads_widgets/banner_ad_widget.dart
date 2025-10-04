// lib/core/widgets/ads_widgets/banner_ad_widget.dart
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_requested) {
        _requested = true;
        _ads.loadBannerAd(context);
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
    final ready = _ads.isBannerAdReady && ad != null;

    if (ready) {
      // ملاحظة: نفس الـ BannerAd ماينفعش يتعرض في أكتر من مكان في نفس الوقت
      return SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      );
    }

    // Placeholder ثابت لمنع “قفزة” الواجهة
    return SizedBox(height: AdSize.banner.height.toDouble());
  }
}
