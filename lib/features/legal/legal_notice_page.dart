import 'package:flutter/material.dart';

import 'legal_section_card.dart';

/// 오탐 안내 · 면책 · 데이터 처리 고지.
/// 보안 SaaS·안티바이러스 업계의 일반적인 한국어 안내 문구 (Naver Whale 보안 알림,
/// V3 모바일 시큐리티, AhnLab SmartGuard, 후후 보이스피싱 차단 등)에서 공통적으로
/// 사용되는 표현을 참고해 정리했다. 법적 자문 후 회사 명의로 교체할 수 있다.
class LegalNoticePage extends StatelessWidget {
  const LegalNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('오탐·면책 안내')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LegalSectionCard(
                title: '1. 탐지 결과의 성격',
                body:
                    '본 앱이 표시하는 「스미싱 의심」 경고는 자동화된 분석 엔진 및 서버 데이터베이스에 의한 '
                    '확률 기반 판단입니다. 안전(0000) 판정도 마찬가지로 분석 시점의 정보를 기준으로 한 추정이며, '
                    '모든 악성 URL이 100% 탐지되거나, 모든 정상 URL이 100% 안전으로 판정되는 것을 보장하지 않습니다.',
              ),
              LegalSectionCard(
                title: '2. 오탐(False Positive) 가능성',
                body:
                    '다음과 같은 경우 정상 페이지가 위험으로 분류될 수 있습니다.\n'
                    '  • 단축 URL(bit.ly, t.co, naver.me 등) 및 임시 리다이렉트 서비스\n'
                    '  • 게시판·블로그·커뮤니티 등 사용자 작성 콘텐츠가 포함된 도메인\n'
                    '  • 신규로 등록되어 평판 데이터가 부족한 도메인\n'
                    '  • 도메인 이름이 알려진 피싱 키워드(login, secure, account 등)와 유사한 경우\n\n'
                    '경고가 표시되더라도 해당 사이트가 반드시 악성임을 의미하지는 않으며, 사용자는 본문·발신자·'
                    '도메인을 종합적으로 판단해 접속 여부를 결정해야 합니다.',
              ),
              LegalSectionCard(
                title: '3. 미탐(False Negative) 가능성',
                body:
                    '신규 도메인·실시간 생성 URL·DB에 미반영된 도메인은 「안전」으로 표시될 수 있습니다. '
                    '본 앱의 「안전」 판정은 위험이 없다는 보장이 아니며, 안전이라는 표시만 보고 의심 메시지의 '
                    '링크를 무조건 신뢰해서는 안 됩니다.',
              ),
              LegalSectionCard(
                title: '4. 본 앱이 차단하지 않는 항목',
                body:
                    '본 앱은 사용자에게 경고만 제공하며, 다음 행위를 강제로 차단하거나 우회하지 않습니다.\n'
                    '  • 브라우저의 페이지 이동 / 자바스크립트 실행 / 다운로드\n'
                    '  • 통신사·운영체제·다른 보안 앱의 별도 판단\n'
                    '  • 금융앱·결제앱·인증앱의 자체 동작\n\n'
                    '의심되는 페이지의 실제 차단·신고는 한국인터넷진흥원(KISA) 118, 경찰청 사이버수사국 또는 '
                    '해당 금융기관·통신사의 안내에 따라 별도로 수행해야 합니다.',
              ),
              LegalSectionCard(
                title: '5. 면책 조항',
                body:
                    '본 앱은 사용자의 보안 의사 결정을 보조하기 위한 「참고용 도구」로 제공됩니다. '
                    '본 앱의 판정·경고·미경고로 인해 사용자 또는 제3자에게 발생한 직접·간접·부수적·결과적 손해'
                    '(데이터 손실, 금전 피해, 명예 훼손, 영업 손실 등)에 대해, 관련 법령이 허용하는 최대 범위에서 '
                    '운영사는 어떠한 책임도 부담하지 않습니다.\n\n'
                    '본 앱은 백신·EDR·MDM 등 전문 보안 제품을 대체하지 않으며, 금융사기·피싱·해킹 피해에 대한 '
                    '구제·환급의 근거가 되지 않습니다.',
              ),
              LegalSectionCard(
                title: '6. 데이터 처리',
                body:
                    '본 앱은 스미싱 판정을 위해 다음 데이터를 서버에 전송할 수 있습니다.\n'
                    '  • 사용자 단말에서 추출된 URL 문자열\n'
                    '  • 단말 식별을 위한 익명 userid (서버 발급, ANDROID_ID 기반)\n\n'
                    '메시지 본문·발신자 번호·연락처는 서버에 저장되지 않으며, 단말 내부의 알림 카드 표시·로컬 '
                    '타임라인(최대 30일·200건)에만 사용됩니다. 본 앱은 통화 내용·금융 계좌·SMS 인증번호를 '
                    '수집하지 않습니다.',
              ),
              LegalSectionCard(
                title: '7. 신고·문의',
                body:
                    '오탐 신고 또는 정상 사이트의 차단 해제 요청은 운영사 고객센터로 연락 주십시오. 본 앱은 '
                    '내부 통계 목적으로 사용자 신고 내역을 비식별 처리해 보관할 수 있으며, 이는 탐지 품질 개선 '
                    '외의 용도로 이용되지 않습니다.',
              ),
              const SizedBox(height: 12),
              Text(
                '본 안내는 일반적인 안티스미싱 서비스 약관·면책 조항을 참고해 작성된 초안입니다. '
                '정식 배포 전 법률 자문을 받아 운영사 명의의 약관·개인정보 처리방침으로 교체하는 것을 권장합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '문서 기준일: ${DateTime.now().year}년',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
