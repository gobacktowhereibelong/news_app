import 'package:flutter/foundation.dart';
import '../models/article.dart';

/// Provider untuk mengelola bookmark/favorit artikel dalam memori.
/// Melatih Learning Objective 3: State bersama (shared state) lewat Provider.
class BookmarkProvider with ChangeNotifier {
  final List<Article> _bookmarkedArticles = [];

  /// Daftar artikel yang dibookmark (read-only unmodifiable list).
  List<Article> get bookmarkedArticles =>
      List.unmodifiable(_bookmarkedArticles);

  /// Jumlah artikel yang ada di bookmark.
  int get count => _bookmarkedArticles.length;

  /// Mengecek apakah suatu artikel sudah ditandai sebagai bookmark.
  bool isBookmarked(Article article) {
    return _bookmarkedArticles.any((item) => item.id == article.id);
  }

  /// Menambah atau menghapus artikel dari bookmark (toggle).
  void toggleBookmark(Article article) {
    final index = _bookmarkedArticles.indexWhere((item) => item.id == article.id);
    if (index >= 0) {
      _bookmarkedArticles.removeAt(index);
    } else {
      _bookmarkedArticles.add(article);
    }
    notifyListeners();
  }

  /// Menghapus artikel tertentu dari bookmark.
  void removeBookmark(Article article) {
    final beforeLength = _bookmarkedArticles.length;
    _bookmarkedArticles.removeWhere((item) => item.id == article.id);
    if (_bookmarkedArticles.length != beforeLength) {
      notifyListeners();
    }
  }

  /// Mengosongkan semua bookmark (opsional).
  void clearBookmarks() {
    if (_bookmarkedArticles.isNotEmpty) {
      _bookmarkedArticles.clear();
      notifyListeners();
    }
  }
}
