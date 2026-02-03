# 読書進捗管理 Flutter アプリ 実装計画

読書進捗管理アプリを iOS / Android / Web 対応で新規作成します。

## User Review Required

> [!IMPORTANT]
> **コード生成の制限**: 仕様書に従い、`build_runner` を使用したコード生成（`.g.dart` ファイル）は行いません。Riverpod は手動実装、JSON シリアライゼーションも手動実装となります。

## Proposed Changes

### プロジェクト作成

現在のディレクトリに Flutter プロジェクトを新規作成します。

```bash
flutter create --project-name reading_progress_app --platforms ios,android,web ./
```

---

### 依存パッケージ

| パッケージ | 用途 |
|-----------|------|
| `flutter_riverpod` | 状態管理 |
| `go_router` | 宣言的ルーティング |
| `uuid` | 書籍ID生成 |
| `golden_toolkit` | Golden Test (dev) |

---

### ディレクトリ構造 (レイヤード・アーキテクチャ)

```
lib/
├── main.dart
├── app.dart                  # MaterialApp 定義
├── fundamental/              # 基盤層
│   ├── logger.dart
│   └── base_view_model.dart
├── domain/                   # ドメイン層
│   ├── value_objects/
│   │   ├── book_id.dart
│   │   └── reading_progress.dart
│   └── entities/
│       └── book.dart
├── application/              # アプリケーション層
│   ├── providers/
│   │   └── book_list_provider.dart
│   └── use_cases/
│       ├── register_book.dart
│       ├── update_progress.dart
│       └── delete_book.dart
├── presentation/             # プレゼンテーション層
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── reading_book_page.dart
│   │   ├── reading_book_graph_page.dart
│   │   └── settings_page.dart
│   ├── view_models/
│   │   └── home_view_model.dart
│   └── widgets/
│       ├── book_card.dart
│       ├── donut_chart.dart
│       └── celebration_overlay.dart
└── infrastructure/           # インフラ層（将来拡張用）
    └── repositories/
```

---

### 画面構成

| 画面 | ルート | 説明 |
|------|--------|------|
| ホーム画面 | `/` | 書籍一覧、進捗達成・応援演出のオーバーレイ |
| 書籍詳細画面 | `/book/:id` | 読了ページ・感想の入力フォーム |
| グラフ画面 | `/book/:id/graph` | ドーナツチャート表示 |
| 設定画面 | `/settings` | 新規登録、デバッグスイッチ |

---

### 主要機能実装

#### 1. 書籍管理機能
- 書籍エンティティ: `id`, `title`, `totalPages`, `currentPage`, `note`
- CRUD 操作を `Notifier` で状態管理

#### 2. 進捗視覚化機能
- カスタム `CustomPainter` でドーナツチャート描画
- `AnimationController` による滑らかなアニメーション
- `HapticFeedback` によるタップフィードバック

#### 3. 応援・演出機能
- 進捗率の節目（10%, 50%, 80%, 100%）で達成アニメーション発火
- 設定画面のデバッグスイッチで10秒後に応援/叱咤演出をシミュレート

---

## Verification Plan

### Automated Tests

```bash
# 静的解析
dart analyze

# ビルド確認
flutter build web --release
```

### Manual Verification

- Chrome ブラウザでアプリを起動し動作確認
- 書籍登録・進捗更新・グラフ表示の動作確認
