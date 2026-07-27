import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/timeline_store.dart';
import '../../main.dart' show kBrandSeed;
import '../../services/native_bridge.dart';
import '../../services/user_session.dart';
import '../home/guard_status_page.dart';

/// 메인 히어로 카드와 동일한 블루 그radient 톤.
const _splashGradientTop = Color(0xFF3B82F6);
const _splashGradientBottom = Color(0xFF1D4ED8);

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  static const _minSplashDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    NativeBridge.instance.startListening();
    await TimelineStore.instance.load();
    final ok = await UserSession.instance.bootstrap();

    final elapsed = DateTime.now().difference(started);
    final remaining = _minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    if (!ok) {
      await _showUnavailableDialog();
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GuardStatusPage()),
    );
  }

  Future<void> _showUnavailableDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('알림'),
        content: const Text('현재 서비스 이용이 불가능 합니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              SystemNavigator.pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kBrandSeed,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_splashGradientTop, _splashGradientBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  'assets/icon/guard_shield.png',
                  width: 96,
                  height: 96,
                ),
                const SizedBox(height: 16),
                const Text(
                  '경남 안심링크',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(flex: 1),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 28),
                  child: _SplashCertFooter(),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CertBadgeData {
  const _CertBadgeData({required this.label, required this.asset});

  final String label;
  final String asset;
}

/// 스플래시 하단 — 인증·수상 마크 (라벨 + 균등 카드).
class _SplashCertFooter extends StatelessWidget {
  const _SplashCertFooter();

  static const _badges = <_CertBadgeData>[
    _CertBadgeData(
      label: '가족친화 우수 기업',
      asset: 'assets/cert_logos/cert_family_friendly.png',
    ),
    _CertBadgeData(
      label: '스타기업',
      asset: 'assets/cert_logos/cert_star_company.png',
    ),
    _CertBadgeData(
      label: '벤처기업인증',
      asset: 'assets/cert_logos/cert_venture_kibo.png',
    ),
    _CertBadgeData(
      label: '2024 SNS대상',
      asset: 'assets/cert_logos/cert_sns_award_2024.png',
    ),
  ];

  static const _labelStyle = TextStyle(
    fontSize: 9.5,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: Color(0xE6FFFFFF),
    letterSpacing: -0.2,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _badges.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _CertBadgeTile(badge: _badges[i])),
          ],
        ],
      ),
    );
  }
}

class _CertBadgeTile extends StatelessWidget {
  const _CertBadgeTile({required this.badge});

  final _CertBadgeData badge;

  static const _logoHeight = 48.0;
  static const _labelAreaHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _logoHeight,
          width: double.infinity,
          child: Image.asset(
            badge.asset,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _labelAreaHeight,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                badge.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: _SplashCertFooter._labelStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
