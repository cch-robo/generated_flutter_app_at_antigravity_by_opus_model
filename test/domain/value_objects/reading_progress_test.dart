/// 読書進捗値オブジェクトのユニットテスト
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_progress_app/domain/value_objects/reading_progress.dart';

void main() {
  group('ReadingProgress', () {
    group('initial', () {
      test('初期状態は読了ページ0であること', () {
        // Act
        final progress = ReadingProgress.initial(300);

        // Assert
        expect(progress.currentPage, 0);
        expect(progress.totalPages, 300);
      });
    });

    group('progressRate', () {
      test('進捗率が正しく計算されること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 150, totalPages: 300);

        // Assert
        expect(progress.progressRate, 0.5);
      });

      test('0ページの場合は進捗率0であること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 0, totalPages: 300);

        // Assert
        expect(progress.progressRate, 0.0);
      });

      test('全ページ読了の場合は進捗率1であること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 300, totalPages: 300);

        // Assert
        expect(progress.progressRate, 1.0);
      });
    });

    group('progressPercentage', () {
      test('進捗率がパーセント表示されること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 150, totalPages: 300);

        // Assert
        expect(progress.progressPercentage, 50);
      });
    });

    group('remainingPages', () {
      test('残りページ数が正しく計算されること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 150, totalPages: 300);

        // Assert
        expect(progress.remainingPages, 150);
      });
    });

    group('isCompleted', () {
      test('全ページ読了の場合trueを返すこと', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 300, totalPages: 300);

        // Assert
        expect(progress.isCompleted, isTrue);
      });

      test('未読了の場合falseを返すこと', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 150, totalPages: 300);

        // Assert
        expect(progress.isCompleted, isFalse);
      });
    });

    group('hasReachedMilestone', () {
      test('10%達成時にマイルストーンに到達していること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 30, totalPages: 300);

        // Assert
        expect(progress.hasReachedMilestone(10), isTrue);
        expect(progress.hasReachedMilestone(50), isFalse);
      });

      test('50%達成時にマイルストーンに到達していること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 150, totalPages: 300);

        // Assert
        expect(progress.hasReachedMilestone(10), isTrue);
        expect(progress.hasReachedMilestone(50), isTrue);
        expect(progress.hasReachedMilestone(80), isFalse);
      });

      test('100%達成時に全マイルストーンに到達していること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 300, totalPages: 300);

        // Assert
        expect(progress.hasReachedMilestone(10), isTrue);
        expect(progress.hasReachedMilestone(50), isTrue);
        expect(progress.hasReachedMilestone(80), isTrue);
        expect(progress.hasReachedMilestone(100), isTrue);
      });
    });

    group('updateProgress', () {
      test('進捗を更新できること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 0, totalPages: 300);

        // Act
        final updated = progress.updateProgress(150);

        // Assert
        expect(updated.currentPage, 150);
        expect(updated.totalPages, 300);
      });

      test('総ページ数を超える値はクランプされること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 0, totalPages: 300);

        // Act
        final updated = progress.updateProgress(500);

        // Assert
        expect(updated.currentPage, 300);
      });

      test('負の値はクランプされること', () {
        // Arrange
        const progress = ReadingProgress(currentPage: 100, totalPages: 300);

        // Act
        final updated = progress.updateProgress(-10);

        // Assert
        expect(updated.currentPage, 0);
      });
    });

    group('equality', () {
      test('同じ値のReadingProgressは等しいこと', () {
        // Arrange
        const progress1 = ReadingProgress(currentPage: 150, totalPages: 300);
        const progress2 = ReadingProgress(currentPage: 150, totalPages: 300);

        // Assert
        expect(progress1, equals(progress2));
      });

      test('異なる値のReadingProgressは等しくないこと', () {
        // Arrange
        const progress1 = ReadingProgress(currentPage: 150, totalPages: 300);
        const progress2 = ReadingProgress(currentPage: 100, totalPages: 300);

        // Assert
        expect(progress1, isNot(equals(progress2)));
      });
    });
  });
}
