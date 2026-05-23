import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/scan_result.dart';
import '../utils/korean_date_format.dart';
import '../utils/message_body_format.dart';

/// 타임라인 · 메시지 상세 보기
class MessageDetailSheet extends StatefulWidget {
  const MessageDetailSheet({super.key, required this.result});

  final ScanResult result;

  static Future<void> show(BuildContext context, ScanResult result) {
    if (formatMessageBodyForDisplay(result).isEmpty) return Future.value();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MessageDetailSheet(result: result),
    );
  }

  @override
  State<MessageDetailSheet> createState() => _MessageDetailSheetState();

  static IconData sourceIcon(UrlSource source) => switch (source) {
        UrlSource.kakao => Icons.chat_bubble_rounded,
        UrlSource.telegram => Icons.send_rounded,
        UrlSource.line => Icons.forum_rounded,
        UrlSource.sms || UrlSource.smsNotif => Icons.sms_rounded,
        UrlSource.browser => Icons.language_rounded,
        _ => Icons.notifications_rounded,
      };

  static Color sourceColor(UrlSource source) => switch (source) {
        UrlSource.kakao => const Color(0xFFFEE500),
        UrlSource.telegram => const Color(0xFF29B6F6),
        UrlSource.line => const Color(0xFF06C755),
        UrlSource.sms || UrlSource.smsNotif => const Color(0xFF90CAF9),
        UrlSource.browser => const Color(0xFF81C784),
        _ => const Color(0xFFFFE082),
      };
}

class _MessageDetailSheetState extends State<MessageDetailSheet> {
  bool _copied = false;
  Timer? _copiedResetTimer;

  ScanResult get result => widget.result;

  @override
  void dispose() {
    _copiedResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageBody = formatMessageBodyForDisplay(result);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _Header(result: result),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MetaSection(result: result),
                      const SizedBox(height: 16),
                      _UrlSection(url: result.url),
                      const SizedBox(height: 16),
                      if (messageBody.isNotEmpty)
                        _MessageBodySection(text: messageBody),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                copied: _copied,
                onClose: () => Navigator.pop(context),
                onCopy: () => _copyAll(messageBody),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyAll(String messageBody) async {
    final buffer = StringBuffer()
      ..writeln('[${result.source.displayName}]')
      ..writeln(formatKoreanDateTime(result.checkedAt))
      ..writeln(result.url)
      ..writeln()
      ..write(messageBody);
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;

    HapticFeedback.lightImpact();
    _copiedResetTimer?.cancel();
    setState(() => _copied = true);
    _copiedResetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final color = MessageDetailSheet.sourceColor(result.source);
    final icon = MessageDetailSheet.sourceIcon(result.source);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black87, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.senderTitle?.trim().isNotEmpty == true
                      ? result.senderTitle!.trim()
                      : result.source.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.source.displayName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.resultLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaSection extends StatelessWidget {
  const _MetaSection({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '탐지 시각',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatKoreanDateTime(result.checkedAt),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UrlSection extends StatelessWidget {
  const _UrlSection({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '탐지 URL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF90CAF9)),
          ),
          child: SelectableText(
            url,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBodySection extends StatelessWidget {
  const _MessageBodySection({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mail_outline, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              '메시지 전문',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SelectableText(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF37474F),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.copied,
    required this.onClose,
    required this.onCopy,
  });

  final bool copied;
  final VoidCallback onClose;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '클립보드에 복사했습니다',
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState:
                copied ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: copied ? null : onCopy,
                  icon: Icon(
                    copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 18,
                  ),
                  label: Text(copied ? '복사 완료' : '전체 복사'),
                  style: copied
                      ? OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF81C784)),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                  ),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
