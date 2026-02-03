/// Domain層の書籍エンティティ
library;

import 'package:reading_progress_app/domain/value_objects/book_id.dart';
import 'package:reading_progress_app/domain/value_objects/reading_progress.dart';

/// 書籍エンティティ
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.progress,
    this.note = '',
  });

  /// 新規書籍を作成
  factory Book.create({required String title, required int totalPages}) {
    return Book(
      id: BookId.generate(),
      title: title,
      progress: ReadingProgress.initial(totalPages),
    );
  }

  final BookId id;
  final String title;
  final ReadingProgress progress;
  final String note;

  /// 総ページ数
  int get totalPages => progress.totalPages;

  /// 読了ページ数
  int get currentPage => progress.currentPage;

  /// 進捗率（パーセント）
  int get progressPercentage => progress.progressPercentage;

  /// 読了済みかどうか
  bool get isCompleted => progress.isCompleted;

  /// 進捗を更新
  Book updateProgress(int newCurrentPage) {
    return Book(
      id: id,
      title: title,
      progress: progress.updateProgress(newCurrentPage),
      note: note,
    );
  }

  /// メモを更新
  Book updateNote(String newNote) {
    return Book(id: id, title: title, progress: progress, note: newNote);
  }

  /// コピーを作成
  Book copyWith({
    BookId? id,
    String? title,
    ReadingProgress? progress,
    String? note,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Book && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Book(id: $id, title: $title, progress: $progress, note: $note)';
}
