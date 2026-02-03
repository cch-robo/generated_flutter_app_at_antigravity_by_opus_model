/// Presentation層のルーティング定義
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_progress_app/presentation/pages/home_page.dart';
import 'package:reading_progress_app/presentation/pages/reading_book_graph_page.dart';
import 'package:reading_progress_app/presentation/pages/reading_book_page.dart';
import 'package:reading_progress_app/presentation/pages/settings_page.dart';

/// アプリケーションのルート定義
class AppRouter {
  AppRouter._();

  /// ルート名
  static const String home = '/';
  static const String book = '/book/:id';
  static const String bookGraph = '/book/:id/graph';
  static const String settings = '/settings';

  /// GoRouterインスタンス
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: book,
        name: 'book',
        builder: (context, state) {
          final bookId = state.pathParameters['id'] ?? '';
          return ReadingBookPage(bookId: bookId);
        },
      ),
      GoRoute(
        path: bookGraph,
        name: 'bookGraph',
        builder: (context, state) {
          final bookId = state.pathParameters['id'] ?? '';
          return ReadingBookGraphPage(bookId: bookId);
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'ページが見つかりません',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('ホームに戻る'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
