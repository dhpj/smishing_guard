import 'package:flutter_test/flutter_test.dart';
import 'package:smishing_guard/core/url_extractor.dart';

void main() {
  test('extracts http and www urls', () {
    const text = '안녕 http://evil-phish.example/x www.test.com/path';
    final urls = UrlExtractor.extract(text);
    expect(urls.length, greaterThanOrEqualTo(2));
    expect(urls.any((u) => u.contains('evil-phish')), isTrue);
  });

  test('extracts https url embedded in multiline Korean text', () {
    const text = '''이렇게 문장 사이에 끼여 있어도
가능 한 부분이지 ?
https://example.com/path/to/page.html
그래야할거야 ….''';
    final urls = UrlExtractor.extract(text);
    expect(urls.length, 1);
    expect(urls.first, contains('example.com/path/to/page.html'));
  });

  test('extracts humoruniv sitemap url', () {
    const text = '링크 https://m.humoruniv.com/sitemap.html 확인';
    final urls = UrlExtractor.extract(text);
    expect(urls.length, 1);
    expect(urls.first, 'https://m.humoruniv.com/sitemap.html');
  });
}
