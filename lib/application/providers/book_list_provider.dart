/// Application層の書籍一覧状態管理Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reading_progress_app/domain/entities/book.dart';
import 'package:reading_progress_app/domain/value_objects/book_id.dart';

/// 書籍一覧の状態を管理するNotifier
class BookListNotifier extends Notifier<List<Book>> {
  @override
  List<Book> build() {
    return [];
  }

  /// 書籍を登録
  void registerBook({required String title, required int totalPages}) {
    final newBook = Book.create(title: title, totalPages: totalPages);
    state = [...state, newBook];
  }

  /// 書籍の進捗を更新
  void updateProgress(BookId bookId, int currentPage) {
    state = state.map((book) {
      if (book.id == bookId) {
        return book.updateProgress(currentPage);
      }
      return book;
    }).toList();
  }

  /// 書籍のメモを更新
  void updateNote(BookId bookId, String note) {
    state = state.map((book) {
      if (book.id == bookId) {
        return book.updateNote(note);
      }
      return book;
    }).toList();
  }

  /// 書籍を削除
  void deleteBook(BookId bookId) {
    state = state.where((book) => book.id != bookId).toList();
  }

  /// 書籍をIDで検索
  Book? findById(BookId bookId) {
    try {
      return state.firstWhere((book) => book.id == bookId);
    } catch (_) {
      return null;
    }
  }
}

/// 書籍一覧のProvider
final bookListProvider = NotifierProvider<BookListNotifier, List<Book>>(
  BookListNotifier.new,
);

/// 特定の書籍を取得するProvider
final bookByIdProvider = Provider.family<Book?, String>((ref, bookId) {
  final books = ref.watch(bookListProvider);
  try {
    return books.firstWhere((book) => book.id.value == bookId);
  } catch (_) {
    return null;
  }
});
