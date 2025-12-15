# CLAUDE.md

## 1. プロジェクト概要

このプロジェクトは、推し活（ヲタ活）のための機能（スケジュール管理、家計簿、会話練習、レポ作成）を統合したiOSネイティブアプリケーションです。

* **アプリ名:** ヲタ活サポート
* **プラットフォーム:** iOS 14+ (iPhone, iPad互換)
* **コア技術スタック:** SwiftUI、Swift 5、Core Data（プログラマティックモデル定義）
* **データ永続化:** サーバーレス。すべてのデータは端末内のCore Dataおよびファイルシステムに保存

## 2. コア技術とAPIの使用ルール

| 機能カテゴリ | 使用API | 備考 |
| :--- | :--- | :--- |
| **データ永続化** | Core Data | プログラマティックにNSManagedObjectModelを定義（`CoreDataStack.swift`） |
| **音声合成 (TTS)** | `AVSpeechSynthesizer` | 読み上げ速度・ピッチ・音量は`UiSettingsEntity`から取得 |
| **音声認識 (STT)** | `SFSpeechRecognizer` | セッション終了時に一時データを即座に破棄（プライバシー最優先） |
| **画像選択** | `UIImagePickerController` | フォトライブラリからの画像選択に使用 |
| **画像保存** | `ImageStorageService` | ドキュメントディレクトリへのJPEG保存、サムネイル生成 |

## 3. アプリケーション構造

### ディレクトリ構成

```
MeetAndGreet/
├── MeetAndGreetApp.swift     # アプリエントリポイント
├── ContentView.swift         # メインTabView（4タブ）
├── Models/
│   ├── CoreDataStack.swift   # Core Data初期化・モデル定義
│   └── Entities.swift        # NSManagedObjectサブクラス・Enum定義
├── Views/
│   ├── Schedule/
│   │   └── ScheduleListView.swift  # カレンダー・イベント管理
│   ├── Budget/
│   │   └── BudgetView.swift        # 家計簿・グラフ表示
│   ├── Practice/
│   │   └── PracticeListView.swift  # 会話練習・TTS連携
│   └── Report/
│       └── ReportListView.swift    # レポ・チャット形式ログ
├── Services/
│   ├── TtsService.swift            # 音声合成サービス
│   ├── SttService.swift            # 音声認識サービス
│   └── ImageStorageService.swift   # 画像保存サービス
└── Theme/
    └── AppTheme.swift              # テーマ定義・ViewModifier
```

### 重要なファイルと役割

| ファイルパス | 役割 |
| :--- | :--- |
| `Models/CoreDataStack.swift` | Core Dataスタック初期化、プログラマティックなエンティティ定義 |
| `Models/Entities.swift` | 全エンティティクラス、ラッパープロパティ、Enum定義、Date/Number拡張 |
| `Services/TtsService.swift` | AVSpeechSynthesizerのシングルトンサービス、再生・一時停止・停止 |
| `Theme/AppTheme.swift` | Apple/Gameテーマ定義、ThemedCardModifier等のViewModifier |

## 4. メイン機能（4タブ）

### 4.1 スケジュール（ScheduleListView）

| 機能 | 説明 |
| :--- | :--- |
| カレンダー表示 | 月別カレンダーUI、日付タップでイベント表示 |
| イベント管理 | 作成・編集・削除・完了マーク |
| 画像添付 | フォトライブラリから画像を選択しイベントに紐付け |
| カテゴリ | ライブ、接触イベント、リリイベ、フェス、ファンミ、その他 |

**関連コンポーネント:**
- `CalendarView` - 月カレンダー表示
- `ScheduleDetailView` - イベント詳細・画像表示
- `ScheduleEditorView` - イベント作成・編集フォーム
- `ImagePicker` - UIImagePickerControllerのSwiftUIラッパー

### 4.2 家計簿（BudgetView）

| 機能 | 説明 |
| :--- | :--- |
| 月別表示 | 前月・次月ナビゲーション、選択月のみ集計 |
| カテゴリ別グラフ | 円グラフ（ドーナツ型）でカテゴリ別支出を可視化 |
| 支払方法別グラフ | 横棒グラフで支払方法別の割合を表示 |
| 支出一覧 | 詳細表示、編集、削除、支払済み切り替え |

**支出カテゴリ:** チケット、交通費、宿泊、グッズ、食費、プレゼント、その他

**支払方法:** 現金、クレジットカード、電子マネー、振込、その他

**関連コンポーネント:**
- `CategoryChartSection` / `PaymentMethodChartSection` - グラフセクション
- `PieChartView` / `BarChartView` - カスタムグラフ
- `ExpenseDetailView` / `ExpenseEditorView` - 詳細・編集

### 4.3 会話練習（PracticeListView）

| 機能 | 説明 |
| :--- | :--- |
| シナリオ管理 | 会話シナリオの作成・編集・削除 |
| 会話の流れ | 自分/推しの交互セリフ設定 |
| 練習プレイヤー | TTS読み上げ、進捗表示、練習回数カウント |
| お気に入り | シナリオのお気に入り登録 |

**イベントタイプ:** 接触イベント、握手会、撮影会、サイン会、トークイベント、その他

**関連コンポーネント:**
- `PracticeDetailView` - シナリオ詳細・会話の流れ表示
- `PracticePlayerView` - フルスクリーン練習プレイヤー
- `ScriptEditorView` - シナリオ・セリフ編集

### 4.4 レポ（ReportListView）

| 機能 | 説明 |
| :--- | :--- |
| レポート作成 | イベント名、日付、場所、評価（5段階）、メモ |
| 会話ログ | チャット形式で自分/推しのメッセージを記録 |
| メッセージ編集 | 長押しコンテキストメニューで編集・削除 |
| 話者切り替え | 自分（ピンク）/ 推し（紫）の切り替え |

**関連コンポーネント:**
- `ReportDetailView` - レポート詳細・チャットUI
- `ChatBubbleView` - 吹き出しスタイルメッセージ
- `MessageEditorSheet` - メッセージ編集シート
- `ReportEditorView` - レポート基本情報編集

## 5. データモデル（Core Data）

### エンティティ一覧

| エンティティ | 主要属性 | リレーション |
| :--- | :--- | :--- |
| `ScheduleEntity` | title, eventDate, location, category, isCompleted, notes, imageData | なし |
| `ExpenseEntity` | title, amount, category, expenseDate, paymentMethod, isPaid, notes | なし |
| `PracticeScriptEntity` | title, scriptDescription, eventType, practiceCount, isFavorite | dialogues (多) |
| `PracticeDialogueEntity` | content, speakerType, order | script (一) |
| `ReportEntity` | title, eventDate, eventName, location, rating, notes | messages (多) |
| `ChatMessageEntity` | content, messageType, order | report (一) |
| `UiSettingsEntity` | themeRawValue, ttsRate, ttsPitch, ttsVolume, animationsEnabled | なし |

### ラッパープロパティ

各エンティティには`wrapped*`プロパティを定義し、Optional値の安全なアンラップを提供:
```swift
var wrappedTitle: String { title ?? "" }
var wrappedEventDate: Date { eventDate ?? Date() }
```

## 6. テーマシステム

### テーマ定義（AppTheme）

| テーマ | 特徴 |
| :--- | :--- |
| **Apple** | クリーン・ミニマル、青基調、小さめ角丸(12)、薄い影 |
| **Game** | カラフル・ポップ、ピンク/紫基調、大きめ角丸(20)、ボーダー付き |

### ViewModifier

- `ThemedCardModifier` - カード型コンテナスタイル
- `ThemedButtonModifier` - プライマリ/セカンダリボタン
- `ChatBubbleModifier` - チャット吹き出しスタイル

### カラー拡張

```swift
Color.forExpenseCategory(_ category: ExpenseCategory) -> Color
Color.forEventCategory(_ category: EventCategory) -> Color
```

## 7. コーディング規約

1. **Swift API Design Guidelines準拠**
2. **命名規則:** 型名は`UpperCamelCase`、変数・関数は`lowerCamelCase`
3. **Core Dataエンティティ:** `*Entity`サフィックス
4. **ビュー分割:** 機能単位でファイル分割、再利用可能なコンポーネント化
5. **プライバシー:** STT/TTS一時データはセッション終了時に即座に破棄

## 8. Info.plist権限設定

| キー | 用途 |
| :--- | :--- |
| `NSPhotoLibraryUsageDescription` | 画像選択 |
| `NSPhotoLibraryAddUsageDescription` | 画像保存 |
| `NSMicrophoneUsageDescription` | 音声録音（会話練習） |
| `NSSpeechRecognitionUsageDescription` | 音声認識（会話練習） |

---

**開発者への指示:**

- 新機能実装時は既存のエンティティ・サービスを参照
- iOS 14互換のためSwiftDataではなくCore Dataを使用
- TTS/STTの一時データ破棄ルールは厳守（プライバシー保護）
- 画像は`imageData`としてCore Dataに直接保存（Binary Data、外部ストレージ許可）
