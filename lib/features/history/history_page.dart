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

  @override
  Widget build(BuildContext context) {
    final items = TimelineStore.instance.entries;
    return Scaffold(
      appBar: AppBar(title: const Text('타임라인')),
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
