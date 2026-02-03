/// 読書進捗グラフ画面
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_progress_app/application/providers/book_list_provider.dart';
import 'package:reading_progress_app/presentation/widgets/donut_chart.dart';

/// 読書進捗グラフ画面
class ReadingBookGraphPage extends ConsumerWidget {
  const ReadingBookGraphPage({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookByIdProvider(bookId));
    final theme = Theme.of(context);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('書籍が見つかりません')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text('書籍が見つかりません'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('ホームに戻る'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('読書進捗グラフ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/book/$bookId'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 書籍タイトル
                Text(
                  book.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ドーナツチャート
                DonutChart(
                  progress: book.progress.progressRate,
                  currentPage: book.currentPage,
                  totalPages: book.totalPages,
                  size: 280,
                  strokeWidth: 32,
                ),
                const SizedBox(height: 48),

                // 統計情報
                _buildStatCards(context, book),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, dynamic book) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatCard(
          icon: Icons.check_circle_outline,
          label: '読了',
          value: '${book.currentPage}',
          unit: 'ページ',
          color: colorScheme.primary,
        ),
        const SizedBox(width: 16),
        _StatCard(
          icon: Icons.pending_outlined,
          label: '残り',
          value: '${book.progress.remainingPages}',
          unit: 'ページ',
          color: colorScheme.secondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
