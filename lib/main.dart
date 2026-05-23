import 'package:flutter/material.dart';

import 'features/splash/bootstrap_page.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmishingGuardApp());
}

class SmishingGuardApp extends StatelessWidget {
  const SmishingGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smishing Guard',
      navigatorObservers: [appRouteObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const BootstrapPage(),
    );
  }
}
