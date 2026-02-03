/// 書籍新規登録・設定画面
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_progress_app/application/providers/book_list_provider.dart';
import 'package:reading_progress_app/application/providers/celebration_provider.dart';

/// 設定画面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalPagesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  void _registerBook() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final totalPages = int.tryParse(_totalPagesController.text) ?? 0;

    ref
        .read(bookListProvider.notifier)
        .registerBook(title: title, totalPages: totalPages);

    _titleController.clear();
    _totalPagesController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('「$title」を登録しました')));
  }

  void _scheduleCheer() {
    ref.read(celebrationProvider.notifier).scheduleCheer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('10秒後に応援演出を表示します')));
    context.go('/');
  }

  void _scheduleScolding() {
    ref.read(celebrationProvider.notifier).scheduleScolding();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('10秒後に叱咤演出を表示します')));
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 書籍登録セクション
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '新規書籍登録',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: '書籍タイトル',
                          hintText: '読みたい本のタイトル',
                          prefixIcon: Icon(Icons.book),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'タイトルを入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalPagesController,
                        decoration: const InputDecoration(
                          labelText: '総ページ数',
                          hintText: '本のページ数',
                          prefixIcon: Icon(Icons.format_list_numbered),
                          suffixText: 'ページ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ページ数を入力してください';
                          }
                          final pages = int.tryParse(value);
                          if (pages == null || pages <= 0) {
                            return '1以上の数値を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _registerBook,
                          icon: const Icon(Icons.add),
                          label: const Text('登録'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // デバッグセクション
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'デバッグ（演出シミュレーター）',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ボタンを押すと10秒後に演出が表示されます',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _scheduleCheer,
                            icon: const Text('📚'),
                            label: const Text('応援'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _scheduleScolding,
                            icon: const Text('💪'),
                            label: const Text('叱咤'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
