/// Application層の演出イベント管理Provider
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 演出イベントの種類
enum CelebrationEventType {
  /// 進捗達成（10%, 50%, 80%, 100%）
  progressMilestone,

  /// 応援演出
  cheer,

  /// 叱咤演出
  scolding,
}

/// 演出イベント
class CelebrationEvent {
  const CelebrationEvent({
    required this.type,
    required this.milestone,
    this.message = '',
  });

  /// 進捗達成イベント
  factory CelebrationEvent.milestone(int percentage) {
    final message = switch (percentage) {
      10 => 'スタートダッシュ！',
      50 => '折り返し地点！',
      80 => 'もう少し！',
      100 => '読了おめでとう！🎉',
      _ => '',
    };
    return CelebrationEvent(
      type: CelebrationEventType.progressMilestone,
      milestone: percentage,
      message: message,
    );
  }

  /// 応援イベント
  factory CelebrationEvent.cheer() {
    return const CelebrationEvent(
      type: CelebrationEventType.cheer,
      milestone: 0,
      message: '頑張って！📚',
    );
  }

  /// 叱咤イベント
  factory CelebrationEvent.scolding() {
    return const CelebrationEvent(
      type: CelebrationEventType.scolding,
      milestone: 0,
      message: 'もっと集中して！喝！💪',
    );
  }

  final CelebrationEventType type;
  final int milestone;
  final String message;
}

/// 演出イベント管理Notifier
class CelebrationNotifier extends Notifier<CelebrationEvent?> {
  Timer? _timer;

  @override
  CelebrationEvent? build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return null;
  }

  /// 進捗マイルストーン達成時の演出を発火
  void triggerMilestone(int percentage) {
    if (percentage == 0) return; // 0%では発火しない
    state = CelebrationEvent.milestone(percentage);
  }

  /// 応援演出を10秒後に発火（デバッグ用）
  void scheduleCheer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 10), () {
      state = CelebrationEvent.cheer();
    });
  }

  /// 叱咤演出を10秒後に発火（デバッグ用）
  void scheduleScolding() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 10), () {
      state = CelebrationEvent.scolding();
    });
  }

  /// 演出をクリア
  void clear() {
    state = null;
  }

  /// スケジュールをキャンセル
  void cancelSchedule() {
    _timer?.cancel();
  }
}

/// 演出イベントのProvider
final celebrationProvider =
    NotifierProvider<CelebrationNotifier, CelebrationEvent?>(
      CelebrationNotifier.new,
    );
