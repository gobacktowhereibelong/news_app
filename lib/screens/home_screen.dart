import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import 'bookmark_screen.dart';
import 'detail_screen.dart';

/// Layar utama menampilkan daftar artikel berita terkini.
/// Mendukung:
/// - Pull to Refresh (RefreshIndicator)
/// - Pencarian (Search textfield)
/// - Pagination otomatis saat scroll mencapai dasar (Infinite scroll)
/// - Penanganan state: Loading, Error, Loaded, Empty
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    // Memuat data berita saat pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = context.read<NewsProvider>();
      if (newsProvider.status == NewsStatus.initial) {
        newsProvider.fetchArticles();
      }
    });

    // Listener pagination: memuat halaman berikutnya ketika scroll hampir habis
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final newsProvider = context.read<NewsProvider>();
      if (newsProvider.hasMore && !newsProvider.isLoadingMore) {
        newsProvider.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    context.read<NewsProvider>().search(query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<NewsProvider>().clearSearch();
    setState(() {
      _isSearchActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newsProvider = context.watch<NewsProvider>();
    final bookmarkCount = context.watch<BookmarkProvider>().count;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari berita antariksa...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _submitSearch,
              )
            : const Text(
                'Kabar Antariksa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          // Tombol Cari / Tutup Pencarian
          if (_isSearchActive)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Tutup Pencarian',
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Cari Berita',
              onPressed: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
            ),

          // Tombol Navigasi ke Layar Favorit dengan Badge Jumlah
          IconButton(
            tooltip: 'Artikel Favorit ($bookmarkCount)',
            icon: Badge(
              isLabelVisible: bookmarkCount > 0,
              label: Text(
                '$bookmarkCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Icon(Icons.bookmarks_rounded),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarkScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(newsProvider, theme),
    );
  }

  Widget _buildBody(NewsProvider newsProvider, ThemeData theme) {
    // 1. State Loading Awal
    if (newsProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Mengambil berita antariksa terbaru...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // 2. State Error
    if (newsProvider.isError) {
      return ErrorView(
        message: newsProvider.errorMessage ?? 'Gagal memuat artikel.',
        onRetry: () => newsProvider.retry(),
      );
    }

    // 3. State Data Kosong (misal tidak ditemukan saat pencarian)
    if (newsProvider.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada artikel ditemukan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                newsProvider.searchQuery.isNotEmpty
                    ? 'Tidak ada hasil untuk "${newsProvider.searchQuery}". Coba kata kunci lain.'
                    : 'Belum ada berita yang tersedia.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (newsProvider.searchQuery.isNotEmpty) ...[
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: _clearSearch,
                  child: const Text('Reset Pencarian'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 4. State Berhasil (Loaded): Menampilkan ListView dengan Refresh & Pagination
    return RefreshIndicator(
      onRefresh: () => newsProvider.fetchArticles(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: newsProvider.articles.length + (newsProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Indikator loading lebih banyak di bagian paling bawah list
          if (index == newsProvider.articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          final article = newsProvider.articles[index];
          return ArticleCard(
            key: ValueKey(article.id),
            article: article,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
