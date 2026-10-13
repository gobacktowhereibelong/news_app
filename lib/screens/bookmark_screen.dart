import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/article_card.dart';
import 'detail_screen.dart';

/// Layar untuk menampilkan daftar artikel yang disimpan (Bookmark/Favorit).
/// Melatih LO 3: Konsistensi state bersama lewat Provider.
class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final bookmarks = bookmarkProvider.bookmarkedArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Favorit'),
        actions: [
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Hapus Semua Favorit',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Semua Favorit?'),
                    content: const Text(
                      'Semua artikel yang Anda tandai akan dihapus dari daftar favorit.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          bookmarkProvider.clearBookmarks();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Belum Ada Favorit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tandai artikel menarik dengan ikon bookmark di daftar berita atau halaman detail untuk membacanya nanti.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final article = bookmarks[index];
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
