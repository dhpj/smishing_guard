import 'package:flutter_test/flutter_test.dart';
import 'package:smishing_guard/core/trusted_domain_matcher.dart';

void main() {
  test('normalize strips query from stored URL', () {
    expect(
      TrustedDomainMatcher.normalizePattern(
        'https://bank.com/login?session=abc&utm=1',
      ),
      'bank.com/login',
    );
  });

  test('match URL without query when pattern had query', () {
    const patterns = ['bank.com/login'];
    expect(
      TrustedDomainMatcher.isTrusted(
        'https://bank.com/login?id=999',
        patterns,
      ),
      isTrue,
    );
  });

  test('host-only pattern matches any path', () {
    expect(
      TrustedDomainMatcher.isTrusted('https://safe.example.org/a/b', [
        'safe.example.org',
      ]),
      isTrue,
    );
  });

  test('wildcard host', () {
    expect(
      TrustedDomainMatcher.isTrusted('https://app.kakaobank.com/x', [
        '*.kakaobank.com',
      ]),
      isTrue,
    );
  });
}
