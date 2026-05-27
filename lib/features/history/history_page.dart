import 'package:flutter/material.dart';

import '../../core/scan_result.dart';
import '../../core/timeline_store.dart';
import '../../main.dart';
import '../../utils/korean_date_format.dart';
import '../../utils/message_body_format.dart';
import '../../widgets/ad_banner_carousel.dart';
import '../../widgets/message_detail_sheet.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with RouteAware {
  int _adReloadToken = 0;

  @override
  void initState() {
    super.initState();
    _reloadTimeline();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => _reloadAds();

  @override
  void didPopNext() => _reloadAds();

  void _reloadAds() {
    if (!mounted) return;
    setState(() => _adReloadToken++);
  }

  Future<void> _reloadTimeline() async {
    await TimelineStore.instance.load();
    if (mounted) setState(() {});
  }

  void _showMessageDetail(ScanResult r) {
    MessageDetailSheet.show(context, r);
  }

  Future<void> _confirmClear(int count) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('타임라인을 비울까요?'),
        content: Text(
          '저장된 $count건의 위험 검사 이력이 모두 삭제됩니다.\n'
          '이 작업은 되돌릴 수 없어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              foregroundColor: const Color(0xFFB91C1C),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('비우기'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await TimelineStore.instance.clear();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('타임라인을 비웠습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = TimelineStore.instance.entries;
    return Scaffold(
      appBar: AppBar(title: const Text('타임라인')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: FilledButton.tonalIcon(
            onPressed: items.isEmpty ? null : () => _confirmClear(items.length),
            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            label: Text(
              items.isEmpty
                  ? '비울 이력 없음'
                  : '타임라인 비우기 (${items.length}건)',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: items.isEmpty
                  ? null
                  : const Color(0xFFFEE2E2),
              foregroundColor: items.isEmpty
                  ? null
                  : const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdBannerCarousel(reloadToken: _adReloadToken),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      '스미싱 주의로 판정된 기록이 없습니다.\n(최대 1개월 · 200건)',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final r = items[i];
                      final displayBody = formatMessageBodyForDisplay(r);
                      final preview = displayBody.isNotEmpty
                          ? truncatePreview(displayBody)
                          : null;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatKoreanDateTime(r.checkedAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.warning_amber,
                                    color: Colors.orange,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r.url,
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${r.source.displayName} · ${r.resultLabel}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (preview != null && preview.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  preview,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade700,
                                      ),
                                ),
                              ],
                              if (displayBody.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => _showMessageDetail(r),
                                    icon: const Icon(Icons.article_outlined),
                                    label: const Text('메시지 상세 보기'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
