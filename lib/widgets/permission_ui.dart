import 'package:flutter/material.dart';

import '../main.dart' show kBrandSeed;
import '../services/permission_rationale.dart';

/// 목록에는 [PermissionCompactRow] 만 두고, 자세한 설명은 [showPermissionGuideSheet] 로 연다.
void showPermissionGuideSheet(
  BuildContext context, {
  required List<PermissionRationaleEntry> entries,
  String title = '권한이 필요한 이유',
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetCtx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.32,
        maxChildSize: 0.92,
        builder: (_, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '항목을 눌러 자세히 볼 수 있습니다. 탐지·경고 목적으로만 사용됩니다.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      color: Colors.grey.shade50,
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        title: Text(
                          e.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                          ),
                        ),
                        subtitle: Text(
                          e.summary,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.3,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.why,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// 메인·설정 권한 목록용 — 한 줄 요약만 표시.
class PermissionCompactRow extends StatelessWidget {
  const PermissionCompactRow({
    super.key,
    required this.entry,
    required this.granted,
    required this.required,
    required this.onTap,
  });

  final PermissionRationaleEntry entry;
  final bool granted;
  final bool required;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final String statusText;
    final Color statusColor;
    if (granted) {
      dotColor = const Color(0xFF22C55E);
      statusText = '허용됨';
      statusColor = const Color(0xFF15803D);
    } else if (required) {
      dotColor = const Color(0xFFDC2626);
      statusText = '필요';
      statusColor = const Color(0xFFB91C1C);
    } else {
      dotColor = const Color(0xFFF59E0B);
      statusText = '선택';
      statusColor = const Color(0xFFB45309);
    }

    return Semantics(
      button: true,
      label: '${entry.title}, $statusText',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.25,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12.5,
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 하단 「권한 안내 보기」 링크.
class PermissionGuideLink extends StatelessWidget {
  const PermissionGuideLink({
    super.key,
    required this.entries,
    this.label = '각 권한이 왜 필요한지 보기',
  });

  final List<PermissionRationaleEntry> entries;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => showPermissionGuideSheet(context, entries: entries),
        icon: Icon(Icons.help_outline, size: 18, color: kBrandSeed),
        label: Text(label, style: TextStyle(color: kBrandSeed)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
