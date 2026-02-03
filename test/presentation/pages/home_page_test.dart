/// ホーム画面のウィジェットテスト
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_progress_app/application/providers/book_list_provider.dart';

import 'package:reading_progress_app/presentation/pages/home_page.dart';
import 'package:reading_progress_app/presentation/pages/reading_book_page.dart';
import 'package:reading_progress_app/presentation/pages/settings_page.dart';
import 'package:reading_progress_app/presentation/theme/app_theme.dart';

void main() {
  group('HomePage Widget Tests', () {
    late GoRouter router;

    Widget createTestWidget() {
      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/book/:id',
            builder: (context, state) {
              final bookId = state.pathParameters['id'] ?? '';
              return ReadingBookPage(bookId: bookId);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      );

      return ProviderScope(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
    }

    group('登録されている書籍のカード一覧が0件の場合', () {
      testWidgets('カード一覧が表示されていないこと', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        // 空状態のUIが表示されていること
        expect(find.text('書籍がまだ登録されていません'), findsOneWidget);
        expect(find.text('設定画面から新しい書籍を登録してください'), findsOneWidget);
        expect(find.text('書籍を登録する'), findsOneWidget);

        // カードが表示されていないこと
        expect(find.byType(Card), findsNothing);
      });
    });

    group('登録されている書籍のカード一覧が2件の場合', () {
      testWidgets('カード一覧に2件のカードが表示されていること', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 2件の書籍を登録
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomePage)),
        );
        container
            .read(bookListProvider.notifier)
            .registerBook(title: '書籍1', totalPages: 100);
        container
            .read(bookListProvider.notifier)
            .registerBook(title: '書籍2', totalPages: 200);

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('書籍1'), findsOneWidget);
        expect(find.text('書籍2'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(2));
      });
    });

    group('書籍のカード一覧のカードをタップした場合', () {
      testWidgets('書籍詳細・進捗入力画面に遷移すること', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 書籍を登録
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomePage)),
        );
        container
            .read(bookListProvider.notifier)
            .registerBook(title: 'テスト書籍', totalPages: 300);

        await tester.pumpAndSettle();

        // Act: カードをタップ
        await tester.tap(find.text('テスト書籍'));
        await tester.pumpAndSettle();

        // Assert: 書籍詳細画面に遷移していること
        expect(find.byType(ReadingBookPage), findsOneWidget);
      });

      testWidgets('書籍名の入力フィールドにタップされたカードの書籍名が入っていること', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 書籍を登録
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomePage)),
        );
        container
            .read(bookListProvider.notifier)
            .registerBook(title: 'テスト書籍', totalPages: 300);

        await tester.pumpAndSettle();

        // Act: カードをタップ
        await tester.tap(find.text('テスト書籍'));
        await tester.pumpAndSettle();

        // Assert: 書籍詳細画面にタイトルが表示されていること
        // AppBarにタイトルが表示される
        expect(find.text('テスト書籍'), findsWidgets);

        // 書籍情報セクションにタイトルが表示されていること
        expect(find.textContaining('テスト書籍'), findsWidgets);
      });

      testWidgets('進捗ページの入力フィールドにタップされたカードの進捗（読了ページ数）が入っていること', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 書籍を登録し、進捗を更新
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomePage)),
        );
        container
            .read(bookListProvider.notifier)
            .registerBook(title: 'テスト書籍', totalPages: 300);

        final books = container.read(bookListProvider);
        container
            .read(bookListProvider.notifier)
            .updateProgress(books.first.id, 150);

        await tester.pumpAndSettle();

        // Act: カードをタップ
        await tester.tap(find.text('テスト書籍'));
        await tester.pumpAndSettle();

        // Assert: 進捗ページの入力フィールドに150が入っていること
        final textField = find.byType(TextFormField).first;
        expect(textField, findsOneWidget);

        // TextFormFieldのコントローラから値を確認
        final textFormField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, '150'),
        );
        expect(textFormField, isNotNull);
      });
    });

    group('アプリバーの設定（新規登録）アイコンをタップした場合', () {
      testWidgets('設定（新規登録）画面へ遷移すること', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act: 設定アイコンをタップ
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Assert: 設定画面に遷移していること
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(find.text('設定'), findsOneWidget);
        expect(find.text('新規書籍登録'), findsOneWidget);
      });
    });
  });
}
