/// 書籍カードウィジェット
library;

import 'package:flutter/material.dart';
import 'package:reading_progress_app/domain/entities/book.dart';

/// 書籍情報を表示するカード
class BookCard extends StatelessWidget {
  const BookCard({required this.book, required this.onTap, super.key});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              Text(
                book.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 進捗バー
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: book.progress.progressRate,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              // 進捗情報
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${book.currentPage} / ${book.totalPages} ページ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(
                        book.progressPercentage,
                        colorScheme,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${book.progressPercentage}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // 読了マーク
              if (book.isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '読了',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(int percentage, ColorScheme colorScheme) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 80) return Colors.teal;
    if (percentage >= 50) return colorScheme.primary;
    if (percentage >= 10) return Colors.orange;
    return Colors.grey;
  }
}
