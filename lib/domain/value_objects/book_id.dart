/// Domain層で使用する書籍IDの値オブジェクト
library;

import 'package:uuid/uuid.dart';

/// 書籍を一意に識別するためのID
class BookId {
  BookId._(this.value);

  /// 新しいBookIdを生成
  factory BookId.generate() {
    return BookId._(const Uuid().v4());
  }

  /// 既存のIDから復元
  factory BookId.fromString(String id) {
    return BookId._(id);
  }

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BookId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
