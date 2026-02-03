/// 書籍詳細・進捗入力画面
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_progress_app/application/providers/book_list_provider.dart';
import 'package:reading_progress_app/application/providers/celebration_provider.dart';
import 'package:reading_progress_app/domain/value_objects/book_id.dart';

/// 書籍詳細・進捗入力画面
class ReadingBookPage extends ConsumerStatefulWidget {
  const ReadingBookPage({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ReadingBookPage> createState() => _ReadingBookPageState();
}

class _ReadingBookPageState extends ConsumerState<ReadingBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentPageController;
  late TextEditingController _noteController;
  int? _previousMilestone;

  @override
  void initState() {
    super.initState();
    _currentPageController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initControllers() {
    final book = ref.read(bookByIdProvider(widget.bookId));
    if (book != null) {
      if (_currentPageController.text.isEmpty) {
        _currentPageController.text = book.currentPage.toString();
      }
      if (_noteController.text.isEmpty) {
        _noteController.text = book.note;
      }
      _previousMilestone ??= _getMilestone(book.progressPercentage);
    }
  }

  int? _getMilestone(int percentage) {
    if (percentage >= 100) return 100;
    if (percentage >= 80) return 80;
    if (percentage >= 50) return 50;
    if (percentage >= 10) return 10;
    return null;
  }

  void _saveProgress() {
    if (!_formKey.currentState!.validate()) return;

    final book = ref.read(bookByIdProvider(widget.bookId));
    if (book == null) return;

    final currentPage = int.tryParse(_currentPageController.text) ?? 0;
    final note = _noteController.text;

    // 進捗を更新
    ref
        .read(bookListProvider.notifier)
        .updateProgress(BookId.fromString(widget.bookId), currentPage);

    // メモを更新
    ref
        .read(bookListProvider.notifier)
        .updateNote(BookId.fromString(widget.bookId), note);

    // マイルストーン達成チェック
    final updatedBook = ref.read(bookByIdProvider(widget.bookId));
    if (updatedBook != null) {
      final newMilestone = _getMilestone(updatedBook.progressPercentage);
      if (newMilestone != null && newMilestone != _previousMilestone) {
        ref.read(celebrationProvider.notifier).triggerMilestone(newMilestone);
        _previousMilestone = newMilestone;
      }
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('進捗を保存しました')));
  }

  void _deleteBook() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('書籍を削除'),
        content: const Text('この書籍を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(bookListProvider.notifier)
                  .deleteBook(BookId.fromString(widget.bookId));
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(bookByIdProvider(widget.bookId));
    final theme = Theme.of(context);

    // 初期値を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initControllers();
    });

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
        title: Text(book.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteBook,
            tooltip: '削除',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 書籍情報カード
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '書籍情報',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('タイトル', book.title),
                      _buildInfoRow('総ページ数', '${book.totalPages}ページ'),
                      _buildInfoRow('進捗', '${book.progressPercentage}%'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 進捗入力
              TextFormField(
                controller: _currentPageController,
                decoration: InputDecoration(
                  labelText: '読了ページ数',
                  hintText: '現在読んでいるページ',
                  suffixText: '/ ${book.totalPages}ページ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ページ数を入力してください';
                  }
                  final page = int.tryParse(value);
                  if (page == null) {
                    return '数値を入力してください';
                  }
                  if (page < 0) {
                    return '0以上の数値を入力してください';
                  }
                  if (page > book.totalPages) {
                    return '総ページ数以下の数値を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // メモ入力
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '感想・メモ',
                  hintText: '読書の感想や気づきを記録しましょう',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // 保存ボタン
              FilledButton.icon(
                onPressed: _saveProgress,
                icon: const Icon(Icons.save),
                label: const Text('保存'),
              ),
              const SizedBox(height: 12),

              // グラフ表示ボタン
              OutlinedButton.icon(
                onPressed: () => context.go('/book/${widget.bookId}/graph'),
                icon: const Icon(Icons.pie_chart_outline),
                label: const Text('グラフを表示'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
