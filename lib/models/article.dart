/// Model data untuk artikel berita.
/// Melatih Learning Objective 4: Mem-parsing data JSON menjadi model Dart.
class Article {
  final int id;
  final String title;
  final String url;
  final String? imageUrl;
  final String newsSite;
  final String? summary;
  final DateTime? publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.url,
    this.imageUrl,
    required this.newsSite,
    this.summary,
    this.publishedAt,
  });

  /// Factory constructor untuk membuat objek [Article] dari JSON Map.
  /// Menangani field yang mungkin bernilai null dari API publik (misal: image_url, summary).
  factory Article.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['published_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['published_at'].toString());
      } catch (_) {
        parsedDate = null;
      }
    }

    return Article(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Tanpa Judul',
      url: json['url'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      newsSite: json['news_site'] as String? ?? 'Sumber tidak diketahui',
      summary: json['summary'] as String?,
      publishedAt: parsedDate,
    );
  }

  /// Konversi objek [Article] kembali menjadi Map (JSON serializable).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
