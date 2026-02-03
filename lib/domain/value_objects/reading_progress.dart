/// Domain層で使用する読書進捗の値オブジェクト
library;

/// 読書進捗を表す値オブジェクト
class ReadingProgress {
  const ReadingProgress({required this.currentPage, required this.totalPages})
    : assert(currentPage >= 0, 'currentPage must be >= 0'),
      assert(totalPages > 0, 'totalPages must be > 0'),
      assert(currentPage <= totalPages, 'currentPage must be <= totalPages');

  /// 初期状態（0ページ読了）
  factory ReadingProgress.initial(int totalPages) {
    return ReadingProgress(currentPage: 0, totalPages: totalPages);
  }

  final int currentPage;
  final int totalPages;

  /// 残りページ数
  int get remainingPages => totalPages - currentPage;

  /// 進捗率（0.0〜1.0）
  double get progressRate {
    if (totalPages == 0) return 0.0;
    return currentPage / totalPages;
  }

  /// 進捗率（パーセント表示、0〜100）
  int get progressPercentage => (progressRate * 100).round();

  /// 読了済みかどうか
  bool get isCompleted => currentPage >= totalPages;

  /// 進捗のマイルストーン（10%, 50%, 80%, 100%）を達成したかチェック
  bool hasReachedMilestone(int percentage) {
    return progressPercentage >= percentage;
  }

  /// 新しい進捗で更新
  ReadingProgress updateProgress(int newCurrentPage) {
    return ReadingProgress(
      currentPage: newCurrentPage.clamp(0, totalPages),
      totalPages: totalPages,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgress &&
          currentPage == other.currentPage &&
          totalPages == other.totalPages;

  @override
  int get hashCode => Object.hash(currentPage, totalPages);

  @override
  String toString() =>
      'ReadingProgress(current: $currentPage, total: $totalPages, $progressPercentage%)';
}
