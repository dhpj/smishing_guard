import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/smishing_api_client.dart';
import '../core/scan_pipeline.dart';

/// 메인·타임라인 공통 광고 배너 (5초 슬라이드, 탭 시 img_link)
class AdBannerCarousel extends StatefulWidget {
  const AdBannerCarousel({super.key, this.reloadToken = 0});

  /// 변경 시 API에서 광고를 다시 불러옴
  final int reloadToken;

  @override
  State<AdBannerCarousel> createState() => _AdBannerCarouselState();
}

class _AdBannerCarouselState extends State<AdBannerCarousel> {
  List<AdImageResponse> _ads = [];
  bool _loading = true;
  int _pageIndex = 0;
  final PageController _controller = PageController();
  Timer? _slideTimer;

  static const _slideInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AdBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) {
      _load();
    }
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ads = await ScanPipeline.instance.fetchAdImages();
    if (!mounted) return;
    setState(() {
      _ads = ads;
      _loading = false;
      _pageIndex = 0;
    });
    if (_controller.hasClients) {
      _controller.jumpToPage(0);
    }
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _slideTimer?.cancel();
    if (_ads.length <= 1) return;
    _slideTimer = Timer.periodic(_slideInterval, (_) {
      if (!_controller.hasClients || _ads.isEmpty) return;
      final current = _controller.page?.round() ?? _pageIndex;
      final next = (current + 1) % _ads.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _openLink(AdImageResponse ad) async {
    final link = ad.imgLink.trim();
    if (link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('광고 링크 주소가 올바르지 않습니다.')),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 4,
        child: LinearProgressIndicator(),
      );
    }
    if (_ads.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 72,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) {
                    setState(() => _pageIndex = i);
                    _startAutoSlide();
                  },
                  itemCount: _ads.length,
                  itemBuilder: (context, index) {
                    final ad = _ads[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: ad.imgLink.trim().isNotEmpty
                            ? () => _openLink(ad)
                            : null,
                        child: Image.network(
                          ad.imgUrl,
                          height: 72,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
                if (_ads.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_ads.length, (i) {
                        final active = i == _pageIndex;
                        return Container(
                          width: active ? 8 : 6,
                          height: active ? 8 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
