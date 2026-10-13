import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';

void main() {
  group('BookmarkProvider Tests', () {
    late BookmarkProvider bookmarkProvider;
    const sampleArticle = Article(
      id: 1,
      title: 'Misi Baru ke Mars',
      url: 'https://example.com/mars',
      newsSite: 'NASA Spaceflight',
      summary: 'Misi eksplorasi rover terbaru.',
    );

    setUp(() {
      bookmarkProvider = BookmarkProvider();
    });

    test('Status awal bookmark kosong', () {
      expect(bookmarkProvider.count, 0);
      expect(bookmarkProvider.bookmarkedArticles, isEmpty);
      expect(bookmarkProvider.isBookmarked(sampleArticle), isFalse);
    });

    test('Menambahkan artikel ke bookmark lewat toggleBookmark', () {
      bookmarkProvider.toggleBookmark(sampleArticle);

      expect(bookmarkProvider.count, 1);
      expect(bookmarkProvider.isBookmarked(sampleArticle), isTrue);
      expect(bookmarkProvider.bookmarkedArticles.first.title, 'Misi Baru ke Mars');
    });

    test('Menghapus artikel dari bookmark lewat toggleBookmark kedua kali', () {
      bookmarkProvider.toggleBookmark(sampleArticle);
      expect(bookmarkProvider.isBookmarked(sampleArticle), isTrue);

      bookmarkProvider.toggleBookmark(sampleArticle);
      expect(bookmarkProvider.count, 0);
      expect(bookmarkProvider.isBookmarked(sampleArticle), isFalse);
    });

    test('removeBookmark menghapus artikel yang sesuai', () {
      bookmarkProvider.toggleBookmark(sampleArticle);
      expect(bookmarkProvider.count, 1);

      bookmarkProvider.removeBookmark(sampleArticle);
      expect(bookmarkProvider.count, 0);
      expect(bookmarkProvider.isBookmarked(sampleArticle), isFalse);
    });

    test('clearBookmarks mengosongkan semua favorit', () {
      const article2 = Article(
        id: 2,
        title: 'Teleskop James Webb',
        url: 'https://example.com/jwst',
        newsSite: 'ESA',
      );

      bookmarkProvider.toggleBookmark(sampleArticle);
      bookmarkProvider.toggleBookmark(article2);
      expect(bookmarkProvider.count, 2);

      bookmarkProvider.clearBookmarks();
      expect(bookmarkProvider.count, 0);
      expect(bookmarkProvider.bookmarkedArticles, isEmpty);
    });
  });
}
