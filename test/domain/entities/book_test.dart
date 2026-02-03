/// 書籍エンティティのユニットテスト
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_progress_app/domain/entities/book.dart';
import 'package:reading_progress_app/domain/value_objects/book_id.dart';
import 'package:reading_progress_app/domain/value_objects/reading_progress.dart';

void main() {
  group('Book', () {
    group('create', () {
      test('新規書籍を作成できること', () {
        // Act
        final book = Book.create(title: 'テスト書籍', totalPages: 300);

        // Assert
        expect(book.title, 'テスト書籍');
        expect(book.totalPages, 300);
        expect(book.currentPage, 0);
        expect(book.note, '');
        expect(book.id.value, isNotEmpty);
      });

      test('書籍IDがユニークであること', () {
        // Act
        final book1 = Book.create(title: '書籍1', totalPages: 100);
        final book2 = Book.create(title: '書籍2', totalPages: 200);

        // Assert
        expect(book1.id.value, isNot(equals(book2.id.value)));
      });
    });

    group('updateProgress', () {
      test('進捗を更新できること', () {
        // Arrange
        final book = Book.create(title: 'テスト書籍', totalPages: 300);

        // Act
        final updatedBook = book.updateProgress(150);

        // Assert
        expect(updatedBook.currentPage, 150);
        expect(updatedBook.progressPercentage, 50);
        expect(updatedBook.id, book.id); // IDは変わらない
      });

      test('総ページ数を超える値は総ページ数にクランプされること', () {
        // Arrange
        final book = Book.create(title: 'テスト書籍', totalPages: 300);

        // Act
        final updatedBook = book.updateProgress(500);

        // Assert
        expect(updatedBook.currentPage, 300);
      });

      test('負の値は0にクランプされること', () {
        // Arrange
        final book = Book.create(title: 'テスト書籍', totalPages: 300);

        // Act
        final updatedBook = book.updateProgress(-10);

        // Assert
        expect(updatedBook.currentPage, 0);
      });
    });

    group('updateNote', () {
      test('メモを更新できること', () {
        // Arrange
        final book = Book.create(title: 'テスト書籍', totalPages: 300);

        // Act
        final updatedBook = book.updateNote('面白い本でした');

        // Assert
        expect(updatedBook.note, '面白い本でした');
        expect(updatedBook.id, book.id); // IDは変わらない
      });
    });

    group('isCompleted', () {
      test('読了済みの場合trueを返すこと', () {
        // Arrange
        final book = Book.create(title: 'テスト書籍', totalPages: 300);

        // Act
        final completedBook = book.updateProgress(300);

        // Assert
        expect(completedBook.isCompleted, isTrue);
      });

      test('未読了の場合falseを返すこと', () {
        // Arrange
        final book = Book.create(title: 'テスト書籍', totalPages: 300);

        // Act
        final inProgressBook = book.updateProgress(150);

        // Assert
        expect(inProgressBook.isCompleted, isFalse);
      });
    });

    group('equality', () {
      test('同じIDの書籍は等しいこと', () {
        // Arrange
        final id = BookId.generate();
        final book1 = Book(
          id: id,
          title: '書籍1',
          progress: ReadingProgress.initial(100),
        );
        final book2 = Book(
          id: id,
          title: '書籍2',
          progress: ReadingProgress.initial(200),
        );

        // Assert
        expect(book1, equals(book2));
      });

      test('異なるIDの書籍は等しくないこと', () {
        // Arrange
        final book1 = Book.create(title: '書籍', totalPages: 100);
        final book2 = Book.create(title: '書籍', totalPages: 100);

        // Assert
        expect(book1, isNot(equals(book2)));
      });
    });
  });
}
