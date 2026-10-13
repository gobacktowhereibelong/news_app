import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/error_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ErrorView menampilkan pesan error dan tombol Coba Lagi',
      (WidgetTester tester) async {
    bool retryPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Koneksi gagal',
            onRetry: () {
              retryPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Gagal Memuat Berita'), findsOneWidget);
    expect(find.text('Koneksi gagal'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));
    expect(retryPressed, isTrue);
  });

  testWidgets('ArticleCard menampilkan judul dan sumber artikel',
      (WidgetTester tester) async {
    const article = Article(
      id: 42,
      title: 'Peluncuran Roket Falcon 9 Berhasil',
      url: 'https://spaceflightnow.com/launch',
      newsSite: 'Spaceflight Now',
      summary: 'Misi kargo CRS berhasil diluncurkan hari ini.',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BookmarkProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: article,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Peluncuran Roket Falcon 9 Berhasil'), findsOneWidget);
    expect(find.text('Spaceflight Now'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
  });
}
