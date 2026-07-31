/// 권한·특수 설정마다 「왜 필요한지」 안내 문구 (설정 마법서 · 메인 권한 카드 공통).
class PermissionRationaleEntry {
  const PermissionRationaleEntry({
    required this.key,
    required this.title,
    required this.summary,
    required this.why,
    this.requiredForProtection = true,
  });

  final String key;
  final String title;
  /// 목록에 보이는 한 줄 요약 (큰 글씨·좁은 화면용).
  final String summary;
  /// 바텀시트·접기 펼치기 안의 상세 설명.
  final String why;
  final bool requiredForProtection;
}

abstract final class PermissionRationales {
  static const postNotifications = PermissionRationaleEntry(
    key: 'postNotifications',
    title: '앱 알림 (Android 13+)',
    summary: '보호 상태·탐지 알림',
    why:
        '보호 기능이 켜진 동안 상태를 안내하고, '
        '「다른 앱 위 표시」가 없을 때 위험 링크 탐지 결과를 알림으로 보여 주기 위해 필요합니다.',
  );

  static const overlay = PermissionRationaleEntry(
    key: 'overlay',
    title: '다른 앱 위에 표시',
    summary: '위험 링크 경고 창',
    why:
        '위험한 링크를 탐지했을 때 메신저·브라우저 화면 위에 경고 창을 띄웁니다. '
        '허용하지 않으면 시스템 알림으로만 안내됩니다.',
  );

  static const notificationListener = PermissionRationaleEntry(
    key: 'notificationListener',
    title: '알림 접근 (문자·카카오톡·텔레그램 등)',
    summary: '문자·메신저 알림 속 링크 검사',
    why:
        '삼성/구글 문자 앱 및 카카오톡, 텔레그램, LINE 등 알림에 포함된 링크를 읽어 검사합니다. '
        '본 앱은 SMS 수신·읽기(RECEIVE_SMS/READ_SMS) 권한을 사용하지 않습니다. '
        '앱·알림 형식에 따라 URL이 알림 본문에 없으면 검사되지 않을 수 있습니다. '
        '대화 전체를 서버에 올리지 않습니다.',
  );

  static const accessibility = PermissionRationaleEntry(
    key: 'accessibility',
    title: '접근성 (브라우저 주소창)',
    summary: '브라우저 주소창만 읽기',
    why:
        'Chrome·Whale·Firefox 등 브라우저의 주소 표시 줄만 읽어 '
        '현재 방문 중인 주소를 검사합니다. '
        '등록된 브라우저에서만 동작하며, 화면의 다른 글·버튼 내용은 수집하지 않습니다.',
  );

  static const batteryOptimization = PermissionRationaleEntry(
    key: 'batteryOptimization',
    title: '배터리 최적화 제외 (권장)',
    summary: '백그라운드 보호 유지',
    why:
        '백그라운드 보호(상시 감시)가 일부 기기에서 끊기지 않도록 합니다. '
        '설정하지 않아도 동작하지만, 검사가 늦어질 수 있습니다.',
    requiredForProtection: false,
  );

  static const setupWizardOrder = <PermissionRationaleEntry>[
    postNotifications,
    overlay,
    notificationListener,
    accessibility,
  ];

  static const mainScreenOrder = <PermissionRationaleEntry>[
    notificationListener,
    accessibility,
    overlay,
    batteryOptimization,
  ];

  static const all = <PermissionRationaleEntry>[
    postNotifications,
    overlay,
    notificationListener,
    accessibility,
    batteryOptimization,
  ];

  static PermissionRationaleEntry? find(String key) {
    for (final e in all) {
      if (e.key == key) return e;
    }
    return null;
  }
}
