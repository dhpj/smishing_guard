import 'package:flutter/material.dart';

import 'features/splash/bootstrap_page.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// 앱 전반 톤의 단일 source-of-truth — 런처 아이콘과 색감을 맞춤.
/// blue-700 (#1D4ED8) 는 신뢰감 있는 청색 톤의 기준선.
const Color kBrandSeed = Color(0xFF1D4ED8);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmishingGuardApp());
}

class SmishingGuardApp extends StatelessWidget {
  const SmishingGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kBrandSeed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: '경남 안심링크',
      navigatorObservers: [appRouteObserver],
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: scheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: scheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          iconTheme: IconThemeData(color: scheme.onPrimary),
        ),
        cardTheme: CardTheme(
          elevation: 1,
          surfaceTintColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const BootstrapPage(),
    );
  }
}
