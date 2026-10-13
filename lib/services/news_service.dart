import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/article.dart';

/// Hasil respons API beserta informasi pagination.
class NewsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Article> results;

  NewsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    final articles = rawResults
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        .toList();

    return NewsResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: articles,
    );
  }
}

/// Service untuk menangani komunikasi jaringan ke Spaceflight News REST API.
/// Melatih Learning Objective 1 & 2:
/// - Menggunakan package http untuk network call.
/// - Menggunakan asynchronous programming (Future, async/await).
class NewsService {
  static const String _baseUrl = 'https://api.spaceflightnewsapi.net/v4/articles';
  final http.Client _client;

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil daftar artikel dengan dukungan pagination dan pencarian.
  ///
  /// [limit]: Jumlah artikel per halaman.
  /// [offset]: Posisi data awal untuk pagination.
  /// [search]: Kata kunci pencarian judul/isi artikel.
  Future<NewsResponse> getArticles({
    int limit = 15,
    int offset = 0,
    String? search,
  }) async {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

    try {
      final response = await _client
          .get(
            uri,
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
        return NewsResponse.fromJson(decodedData);
      } else {
        throw HttpException(
          'Server mengembalikan kode status ${response.statusCode}.',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Waktu permintaan habis. Server memerlukan waktu terlalu lama untuk merespons.',
      );
    } on FormatException {
      throw const FormatException('Format data dari server tidak valid.');
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e is HttpException) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan saat memuat artikel: $e');
    }
  }
}
