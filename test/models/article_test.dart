import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';

void main() {
  group('Article Model Tests', () {
    test('Berhasil mem-parsing JSON lengkap dari Spaceflight News API', () {
      final jsonMap = {
        'id': 40358,
        'title': 'Live coverage: NASA, SpaceX launch',
        'url': 'https://spaceflightnow.com/example-news',
        'image_url': 'https://spaceflightnow.com/image.jpg',
        'news_site': 'Spaceflight Now',
        'summary': 'Liftoff of the Falcon 9 rocket scheduled for today.',
        'published_at': '2026-10-13T01:19:30Z',
      };

      final article = Article.fromJson(jsonMap);

      expect(article.id, 40358);
      expect(article.title, 'Live coverage: NASA, SpaceX launch');
      expect(article.url, 'https://spaceflightnow.com/example-news');
      expect(article.imageUrl, 'https://spaceflightnow.com/image.jpg');
      expect(article.newsSite, 'Spaceflight Now');
      expect(article.summary, 'Liftoff of the Falcon 9 rocket scheduled for today.');
      expect(article.publishedAt, isNotNull);
      expect(article.publishedAt?.year, 2026);
      expect(article.publishedAt?.month, 10);
      expect(article.publishedAt?.day, 13);
    });

    test('Menangani data dengan gambar atau ringkasan null secara aman tanpa error', () {
      final jsonMap = {
        'id': 100,
        'title': 'Berita Antariksa',
        'url': 'https://example.com/space',
        'image_url': null,
        'news_site': 'NASA',
        'summary': null,
        'published_at': null,
      };

      final article = Article.fromJson(jsonMap);

      expect(article.id, 100);
      expect(article.imageUrl, isNull);
      expect(article.summary, isNull);
      expect(article.publishedAt, isNull);
    });

    test('Operator == dan hashCode bekerja berdasarkan ID artikel', () {
      const article1 = Article(
        id: 1,
        title: 'Title A',
        url: 'https://a.com',
        newsSite: 'Site A',
      );

      const article2 = Article(
        id: 1,
        title: 'Title B',
        url: 'https://b.com',
        newsSite: 'Site B',
      );

      expect(article1, equals(article2));
      expect(article1.hashCode, equals(article2.hashCode));
    });

    test('toJson menghasilkan Map yang sesuai', () {
      final article = Article(
        id: 5,
        title: 'Judul Tes',
        url: 'https://test.com',
        imageUrl: 'https://test.com/img.png',
        newsSite: 'BBC Space',
        summary: 'Ringkasan tes',
        publishedAt: DateTime.utc(2026, 10, 13, 8, 30),
      );

      final json = article.toJson();

      expect(json['id'], 5);
      expect(json['title'], 'Judul Tes');
      expect(json['news_site'], 'BBC Space');
      expect(json['published_at'], contains('2026-10-13'));
    });
  });
}
