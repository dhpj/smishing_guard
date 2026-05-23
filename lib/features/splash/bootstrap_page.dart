import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/timeline_store.dart';
import '../../services/native_bridge.dart';
import '../../services/user_session.dart';
import '../home/guard_status_page.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    NativeBridge.instance.startListening();
    await TimelineStore.instance.load();
    final ok = await UserSession.instance.bootstrap();
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
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('서비스 준비 중…'),
          ],
        ),
      ),
    );
  }
}
