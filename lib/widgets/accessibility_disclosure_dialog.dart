import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show kBrandSeed;

/// Google Play 접근성 API 정책 — 앱 내 명시적 고지·동의 (약관·시스템 설명으로 대체 불가).
class AccessibilityDisclosure {
  AccessibilityDisclosure._();

  static const prefKey = 'accessibility_prominent_disclosure_v1';

  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefKey) ?? false;
  }

  /// 동의 이미 있으면 true. 없으면 고지 다이얼로그 표시 후 동의 시 true.
  static Future<bool> ensureConsent(BuildContext context) async {
    if (await hasAccepted()) return true;
    if (!context.mounted) return false;
    final ok = await showAccessibilityProminentDisclosure(context);
    if (ok != true) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);
    return true;
  }
}

/// Play Console 동영상에 녹화할 **접근성 명시적 고지** 화면.
Future<bool?> showAccessibilityProminentDisclosure(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('접근성 서비스 사용 안내'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDBA74)),
                ),
                child: const Text(
                  '경남 안심링크는 장애인 접근성 보조 도구가 아닙니다.\n'
                  '스미싱·피싱 URL 탐지를 위해 Android 접근성 API를 사용합니다.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A3412),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _section(
                '접근하는 정보',
                '• Chrome, Samsung Internet, Whale, Firefox 등 '
                    '등록된 브라우저의 주소 표시 줄(URL)만 읽습니다.\n'
                    '• 보호 기능이 켜져 있을 때만 동작합니다.',
              ),
              _section(
                '접근하지 않는 정보',
                '• 웹페이지 본문, 입력한 비밀번호·개인정보\n'
                    '• 카카오톡·문자 등 다른 앱의 대화 내용\n'
                    '• 화면의 버튼·사진·연락처 등 기타 UI 요소',
              ),
              _section(
                '서버 전송',
                '• 추출된 URL만 스미싱 여부 검사 API로 전송합니다.\n'
                    '• 전체 화면 내용·대화 원문은 전송하지 않습니다.',
              ),
              _section(
                '이용자 선택',
                '• 아래 「동의」를 누르면 Android 접근성 설정 화면으로 이동합니다.\n'
                    '• 설정 → 접근성에서 언제든지 끌 수 있습니다.\n'
                    '• 동의하지 않으면 브라우저 URL 자동 검사는 사용할 수 없습니다.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('동의하지 않음'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('동의하고 접근성 설정으로 이동'),
        ),
      ],
    ),
  );
}

Widget _section(String title, String body) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kBrandSeed,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: const TextStyle(fontSize: 13, height: 1.45),
        ),
      ],
    ),
  );
}
