// 書籍一覧プロバイダーのユニットテスト
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_progress_app/application/providers/book_list_provider.dart';
import 'package:reading_progress_app/domain/value_objects/book_id.dart';

void main() {
  group('BookListNotifier', () {
    late ProviderContainer container;
    late BookListNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(bookListProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('書籍情報登録', () {
      test(
        '書籍のタイトルと総ページ数をパラメータにして、ユニークな書籍IDと読了ページ数が0の書籍情報を新規作成し、書籍一覧に追加登録できること',
        () {
          // Arrange
          const title = 'テスト書籍';
          const totalPages = 300;

          // Act
          notifier.registerBook(title: title, totalPages: totalPages);

          // Assert
          final books = container.read(bookListProvider);
          expect(books.length, 1);

          final book = books.first;
          expect(book.title, title);
          expect(book.totalPages, totalPages);
          expect(book.currentPage, 0); // 読了ページ数が0
          expect(book.id.value, isNotEmpty); // ユニークなIDが生成されている
        },
      );

      test('複数の書籍を登録した場合、それぞれにユニークなIDが割り当てられること', () {
        // Arrange & Act
        notifier.registerBook(title: '書籍1', totalPages: 100);
        notifier.registerBook(title: '書籍2', totalPages: 200);

        // Assert
        final books = container.read(bookListProvider);
        expect(books.length, 2);
        expect(books[0].id.value, isNot(equals(books[1].id.value)));
      });
    });

    group('書籍情報更新', () {
      test('書籍IDと読了ページ数をパラメータにして、書籍一覧から書籍情報を取得し、書籍情報の読了ページ数（進捗）を更新できること', () {
        // Arrange
        notifier.registerBook(title: 'テスト書籍', totalPages: 300);
        final books = container.read(bookListProvider);
        final bookId = books.first.id;
        const newCurrentPage = 150;

        // Act
        notifier.updateProgress(bookId, newCurrentPage);

        // Assert
        final updatedBooks = container.read(bookListProvider);
        final updatedBook = updatedBooks.first;
        expect(updatedBook.currentPage, newCurrentPage);
        expect(updatedBook.progressPercentage, 50);
      });

      test('存在しない書籍IDで更新しようとしても、既存の書籍に影響がないこと', () {
        // Arrange
        notifier.registerBook(title: 'テスト書籍', totalPages: 300);
        final nonExistentId = BookId.generate();

        // Act
        notifier.updateProgress(nonExistentId, 100);

        // Assert
        final books = container.read(bookListProvider);
        expect(books.first.currentPage, 0); // 変更されていない
      });

      test('メモを更新できること', () {
        // Arrange
        notifier.registerBook(title: 'テスト書籍', totalPages: 300);
        final books = container.read(bookListProvider);
        final bookId = books.first.id;
        const note = 'とても面白い本でした';

        // Act
        notifier.updateNote(bookId, note);

        // Assert
        final updatedBooks = container.read(bookListProvider);
        expect(updatedBooks.first.note, note);
      });
    });

    group('書籍情報削除', () {
      test('書籍IDをパラメータにして、書籍一覧から該当する書籍情報を削除できること', () {
        // Arrange
        notifier.registerBook(title: '書籍1', totalPages: 100);
        notifier.registerBook(title: '書籍2', totalPages: 200);
        final books = container.read(bookListProvider);
        final bookIdToDelete = books.first.id;

        // Act
        notifier.deleteBook(bookIdToDelete);

        // Assert
        final remainingBooks = container.read(bookListProvider);
        expect(remainingBooks.length, 1);
        expect(remainingBooks.first.title, '書籍2');
      });

      test('存在しない書籍IDで削除しようとしても、既存の書籍に影響がないこと', () {
        // Arrange
        notifier.registerBook(title: 'テスト書籍', totalPages: 300);
        final nonExistentId = BookId.generate();

        // Act
        notifier.deleteBook(nonExistentId);

        // Assert
        final books = container.read(bookListProvider);
        expect(books.length, 1);
      });
    });

    group('書籍検索', () {
      test('書籍IDで書籍を検索できること', () {
        // Arrange
        notifier.registerBook(title: 'テスト書籍', totalPages: 300);
        final books = container.read(bookListProvider);
        final bookId = books.first.id;

        // Act
        final foundBook = notifier.findById(bookId);

        // Assert
        expect(foundBook, isNotNull);
        expect(foundBook!.title, 'テスト書籍');
      });

      test('存在しない書籍IDで検索するとnullが返ること', () {
        // Arrange
        notifier.registerBook(title: 'テスト書籍', totalPages: 300);
        final nonExistentId = BookId.generate();

        // Act
        final foundBook = notifier.findById(nonExistentId);

        // Assert
        expect(foundBook, isNull);
      });
    });
  });

  group('bookByIdProvider', () {
    test('書籍IDで書籍を取得できること', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(bookListProvider.notifier);
      notifier.registerBook(title: 'テスト書籍', totalPages: 300);
      final books = container.read(bookListProvider);
      final bookId = books.first.id.value;

      // Act
      final book = container.read(bookByIdProvider(bookId));

      // Assert
      expect(book, isNotNull);
      expect(book!.title, 'テスト書籍');

      container.dispose();
    });

    test('存在しない書籍IDで取得するとnullが返ること', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final book = container.read(bookByIdProvider('non-existent-id'));

      // Assert
      expect(book, isNull);

      container.dispose();
    });
  });
}
