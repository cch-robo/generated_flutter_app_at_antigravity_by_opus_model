/// ホーム画面
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_progress_app/application/providers/book_list_provider.dart';
import 'package:reading_progress_app/application/providers/celebration_provider.dart';
import 'package:reading_progress_app/presentation/widgets/book_card.dart';
import 'package:reading_progress_app/presentation/widgets/celebration_overlay.dart';

/// ホーム画面
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(bookListProvider);
    final celebrationEvent = ref.watch(celebrationProvider);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('読書進捗'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.go('/settings'),
                tooltip: '設定',
              ),
            ],
          ),
          body: books.isEmpty
              ? _buildEmptyState(context)
              : _buildBookList(context, books, ref),
        ),
        // 演出オーバーレイ
        if (celebrationEvent != null)
          CelebrationOverlay(
            event: celebrationEvent,
            onDismiss: () => ref.read(celebrationProvider.notifier).clear(),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 96,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              '書籍がまだ登録されていません',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '設定画面から新しい書籍を登録してください',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.add),
              label: const Text('書籍を登録する'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(
    BuildContext context,
    List<dynamic> books,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BookCard(
            book: book,
            onTap: () => context.go('/book/${book.id.value}'),
          ),
        );
      },
    );
  }
}
