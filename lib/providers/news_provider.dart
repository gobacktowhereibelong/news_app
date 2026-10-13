import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_service.dart';

/// Status state jaringan untuk proses pengambilan berita.
/// Melatih Learning Objective 3: Menangani state jaringan (loading, sukses, error).
enum NewsStatus { initial, loading, loaded, error }

class NewsProvider with ChangeNotifier {
  final NewsService _newsService;

  NewsProvider({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  NewsStatus _status = NewsStatus.initial;
  List<Article> _articles = [];
  String? _errorMessage;
  String _searchQuery = '';
  int _offset = 0;
  static const int _limit = 15;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Getters
  NewsStatus get status => _status;
  List<Article> get articles => _articles;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoading => _status == NewsStatus.loading;
  bool get isLoaded => _status == NewsStatus.loaded;
  bool get isError => _status == NewsStatus.error;

  /// Mengambil daftar artikel awal atau me-refresh daftar.
  Future<void> fetchArticles({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _hasMore = true;
    } else {
      _status = NewsStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _newsService.getArticles(
        limit: _limit,
        offset: 0,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _articles = response.results;
      _offset = _articles.length;
      _hasMore = response.next != null;
      _status = NewsStatus.loaded;
      _errorMessage = null;
    } on SocketException catch (e) {
      _status = NewsStatus.error;
      _errorMessage = e.message;
    } on TimeoutException catch (e) {
      _status = NewsStatus.error;
      _errorMessage = e.message ?? 'Waktu permintaan habis.';
    } on HttpException catch (e) {
      _status = NewsStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = NewsStatus.error;
      _errorMessage = 'Gagal memuat berita. Periksa koneksi internet Anda dan coba lagi.';
    } finally {
      notifyListeners();
    }
  }

  /// Memuat halaman berikutnya saat scroll mencapai bawah (pagination).
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _status != NewsStatus.loaded) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _newsService.getArticles(
        limit: _limit,
        offset: _offset,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _articles.addAll(response.results);
      _offset += response.results.length;
      _hasMore = response.next != null && response.results.isNotEmpty;
    } catch (e) {
      // Pada load more, jika gagal kita biarkan artikel yang sudah ada
      // dan tandai hasMore sementara agar tidak looping
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Melakukan pencarian berita berdasarkan kata kunci.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (_searchQuery == trimmed && _status == NewsStatus.loaded) {
      return;
    }
    _searchQuery = trimmed;
    _offset = 0;
    _hasMore = true;
    await fetchArticles();
  }

  /// Menghapus filter pencarian dan memuat ulang berita terbaru.
  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _offset = 0;
    _hasMore = true;
    await fetchArticles();
  }

  /// Tombol coba lagi jika terjadi error.
  Future<void> retry() async {
    await fetchArticles();
  }
}
