# 📄 CLAUDE.md

## 1. プロジェクト概要

このプロジェクトは、推し活（ヲタ活）のための機能（会話リハーサル、レポ作成、スケジュール、家計簿、画像管理）を統合したiOSネイティブアプリケーションです。

* **アプリ名:** ヲタ活サポートアプリ (仮称)
* **プラットフォーム:** iOS (iPhone, iPad互換性考慮)
* **コア技術スタック:** **SwiftUI (iOS 17+)**、**Swift 5.9+**、**SwiftData**
* **データ永続化:** **サーバーレス。** すべてのデータは端末内のSwiftDataおよびファイルシステムに保存されます。

## 2. コア技術とAPIの使用ルール

| 機能カテゴリ | 使用API | 制限事項・規約 |
| :--- | :--- | :--- |
| **データ永続化** | **SwiftData** | すべてのモデルはSwiftDataの`@Model`として定義すること。 |
| **音声合成 (TTS)** | `AVSpeechSynthesizer` | 読み上げ速度（`rate`）はユーザー設定（`UiSettings`モデル）から取得し適用すること。 |
| **音声認識 (STT)** | `SFSpeechRecognizer` | STTの結果と録音ファイルはセッションが終了次第、メモリ/一時ファイルから**即座に破棄**すること（プライバシー最優先）。 |
| **グラフ描画** | **Swift Charts** | 家計簿レポートに利用。データ集計ロジックはViewModelに記述すること。 |
| **通知** | `UserNotifications` | イベント期限、支払い期限など、リマインダー用途のみに使用すること。 |
| **画面キャプチャ** | `UIImageRenderer` | レポの画面保存機能に利用。ユーザーの明示的なアクションでのみ実行すること。 |

## 3. アプリケーション構造と重要なファイル

プロジェクトは標準的な**MVVM-S**（Model-View-ViewModel-Service/Store）アーキテクチャを採用します。

* **アーキテクチャ:** MVVM-Sを採用。データ永続化層（Service/Store）は`SwiftData`が担う。
* **エントリポイント:** `MyApp.swift` (Appエントリポイント)
* **データ永続化:** `DataStore.swift` (SwiftData Containerの初期化とシングルトンアクセス)
* **ビュー階層:** `Views/` ディレクトリ配下に、機能別（`Schedule/`, `Report/`, `Practice/`）でフォルダ分けする。

### 重要なファイルと役割

| ファイルパス | 役割 |
| :--- | :--- |
| `Models/Schedule.swift` | スケジュールのコアデータモデル。リレーションシップを定義。 |
| `Models/ImageAsset.swift` | 画像のメタデータ管理。画像本体のファイルパスと関連付けを行う。 |
| `Services/TtsService.swift` | `AVSpeechSynthesizer`の初期化、再生、速度制御を担うシングルトンサービス。 |
| `Services/SttService.swift` | `SFSpeechRecognizer`の開始/停止、リアルタイム文字起こしを担う。 |
| `Views/Practice/PracticePlayerView.swift` | 会話リハーサル機能のメインプレイヤーUI。STT/TTSサービスと連携。 |

## 4. コーディング規約とスタイル

1.  **Swift API Design Guidelinesの遵守:** Appleの標準ガイドラインに従うこと。
2.  **SwiftUIの構造:**
    * すべてのViewは小さな単位で分割し、カスタムViewとして再利用可能にすること。
    * 大規模な状態は**`@Observable`なViewModel**に持たせ、Viewは可能な限り軽量に保つこと。
3.  **命名規則:** 型名（クラス、モデル）は `UpperCamelCase`、変数・関数名は `lowerCamelCase`。
4.  **コメント:** 公開APIには`///`（Markdown形式）でドキュメントコメントを付与すること。

## 5. UI/UXとテーマ切り替えの規約

アプリ全体で「ゲームUI風」と「Apple風」のテーマ切り替え機能を提供します。

* **切り替え実装:** すべてのカスタムスタイル（色、影、角丸）の定義は、カスタムの**`ViewModifier`**または**`EnvironmentValues`**を通じて行うこと。
* **テーマ適用:** `UiSettings`モデルに `var theme: ThemeStyle` を定義し、ルートViewで読み取って`@Environment`に設定。各コンポーネントはこれに基づきスタイルを適用する。
* **アニメーション規約:**
    * **一貫性:** `withAnimation`、`transition`、`matchedGeometryEffect`を積極的に利用し、滑らかなUXを実現。
    * **チャットアニメーション:** レポのチャット吹き出しは、リストに追加される際、必ず`transition`を使用した**ふわっと浮き出るアニメーション**を適用すること。

## 6. データモデル（SwiftData）規約

提供された要件に基づいてモデルを作成し、リレーションシップを設定します。

| モデル名 | 主要な役割 | リレーション |
| :--- | :--- | :--- |
| **Schedule** | イベント情報、各種期限 | `expenses` (多), `packingTemplate` (一), `relatedImages` (多) |
| **Expense** | 支出項目、集計の基盤 | `event` (Optional), `receiptImage` (Optional) |
| **PackingTemplate** | 持ち物チェックリストの雛形 | `schedules` (逆リレーション) |
| **ImageAsset** | 画像メタデータとファイルパス | `schedules`, `expenses`, `reports` (逆リレーション) |
| **UiSettings** | テーマ、TTS設定、アニメーションON/OFF | シングルインスタンスとしてアプリ全体で参照 |

---

**開発者への指示:**

新しい機能の実装や改修を行う際は、上記の規約と、既存の`Models/`ディレクトリ内の定義を参照してください。特に、**TTS/STTの一時データ破棄ルール**はプライバシー保護のため厳守してください。
