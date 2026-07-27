import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show kBrandSeed;

/// Google Play 접근성·데이터 정책 — 앱 내 명시적 고지·동의 (약관·시스템 설명으로 대체 불가).
class AccessibilityDisclosure {
  AccessibilityDisclosure._();

  static const prefKey = 'accessibility_prominent_disclosure_v2';

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

/// Play Console 동영상에 녹화할 **명시적 고지** 화면.
Future<bool?> showAccessibilityProminentDisclosure(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('데이터 수집 및 접근성 서비스 안내'),
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
                  '경남 안심링크는 장애인 접근성 보조 도구(IsAccessibilityTool)가 아닙니다.\n'
                  '스미싱·피싱 URL 탐지를 위해 아래 데이터를 처리하며, '
                  '동의 후에만 보호 기능·권한 설정을 진행할 수 있습니다.',
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
                'AccessibilityService API (접근성 서비스)',
                '• 사용 API: Android AccessibilityService API\n'
                    '• 수집 데이터: Chrome, Samsung Internet, Whale, Firefox 등 '
                    '등록된 브라우저의 주소 표시 줄(URL) 텍스트\n'
                    '• 수집 목적: 현재 방문 중인 웹 주소의 스미싱·피싱 위험도 검사\n'
                    '• 미수집: 웹페이지 본문, 입력한 비밀번호·개인정보, '
                    '화면의 버튼·사진·연락처 등 기타 UI\n'
                    '• 서버 전송: 추출된 URL만 검사 API로 전송 (화면·대화 원문 미전송)\n'
                    '• 보호 기능이 켜져 있을 때만 동작합니다.',
              ),
              _section(
                'SMS 또는 MMS 메시지',
                '• 수집 데이터: 수신·저장된 문자(SMS/MMS) 본문에서 URL을 추출하기 위해 '
                    '메시지 내용을 단말에서 읽습니다.\n'
                    '• 수집 목적: 문자 속 링크의 스미싱·피싱 위험도 검사\n'
                    '• 서버 전송: 추출된 URL만 전송합니다. 문자·MMS 원문 전체는 서버에 올리지 않습니다.\n'
                    '• 단말 처리: 위험 탐지 시 경고 창에 메시지 미리보기·발신 표시명을 '
                    '단말에서만 표시할 수 있습니다.',
              ),
              _section(
                '기타 인앱 메시지 (알림 접근)',
                '• 수집 데이터: 카카오톡, 텔레그램, LINE 등 메신저 알림에 포함된 '
                    '메시지 텍스트에서 URL을 추출하기 위해 알림 내용을 단말에서 읽습니다.\n'
                    '• 수집 목적: 메신저 알림 속 링크의 스미싱·피싱 위험도 검사\n'
                    '• 서버 전송: 추출된 URL만 전송합니다. 대화 전체·알림 원문은 서버에 올리지 않습니다.\n'
                    '• 앱·알림 형식에 따라 URL이 알림 본문에 없으면 검사되지 않을 수 있습니다.',
              ),
              _section(
                '기타 서버 전송 데이터',
                '• ANDROID_ID: 최초 1회 익명 userid 발급\n'
                    '• userid: URL 검사·광고 API 호출 식별\n'
                    '• 검사 대상 URL: 스미싱 여부 판정',
              ),
              _section(
                '이용자 선택',
                '• 아래 「동의」를 누르면 권한·설정 안내를 계속합니다.\n'
                    '• Android 설정 → 앱·접근성·알림 접근에서 언제든지 끌 수 있습니다.\n'
                    '• 동의하지 않으면 문자·메신저·브라우저 URL 자동 검사를 사용할 수 없습니다.',
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
          child: const Text('동의하고 계속'),
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
