# Otakatsu Support App (ヲタ活サポートアプリ)

A comprehensive iOS app for managing fan activities (推し活/ヲタ活) - helping fans organize events, track expenses, practice conversations, and record memories.

## Features

### Schedule (スケジュール)
- Event management with categories (Live, Meet & Greet, Release Event, Festival, Fan Meeting)
- Date, location, and notes tracking
- Completion status toggle
- Ticket/payment deadline reminders

### Budget (家計簿)
- Expense tracking with categories (Ticket, Transportation, Accommodation, Goods, Food, Gift)
- Payment method tracking (Cash, Credit Card, Electronic Money, Bank Transfer)
- Paid/unpaid status management
- Monthly spending summary

### Practice (会話練習)
- Conversation scenario creation for fan events
- Dialogue flow with user/idol speaker roles
- Text-to-Speech (TTS) integration for practice
- Practice count tracking

### Report (レポ)
- Event memory recording with chat-style messages
- Star rating system
- Event details (name, date, location)
- Photo-style memory journaling

## Tech Stack

- **Platform**: iOS 14.0+
- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **Data Persistence**: Core Data (programmatic model)
- **Architecture**: MVVM with @ObservableObject
- **Speech**: AVSpeechSynthesizer (TTS), SFSpeechRecognizer (STT)

## Project Structure

```
MeetAndGreet/
├── MeetAndGreetApp.swift      # App entry point
├── ContentView.swift          # Main TabView
├── Models/
│   ├── CoreDataStack.swift    # Core Data configuration
│   └── Entities.swift         # NSManagedObject subclasses
├── Views/
│   ├── Schedule/              # Event management views
│   ├── Budget/                # Expense tracking views
│   ├── Practice/              # Conversation practice views with TTS
│   └── Report/                # Memory recording views
├── Services/
│   ├── TtsService.swift       # Text-to-Speech
│   ├── SttService.swift       # Speech-to-Text
│   └── ImageStorageService.swift
└── Theme/
    └── AppTheme.swift         # Apple/Game theme system
```

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5

## Installation

1. Clone the repository
```bash
git clone https://github.com/nakamo119315/iosAppIdol.git
```

2. Open `MeetAndGreet.xcodeproj` in Xcode

3. Build and run on simulator or device

## Privacy

This app requires the following permissions:
- **Speech Recognition**: For conversation practice features
- **Microphone**: For speech-to-text functionality

All speech data is processed locally and destroyed immediately after each session.

## Testing

The project includes comprehensive test coverage:

- **Unit Tests** (17 tests): Core Data entities, date/number formatting, enum validation
- **UI Tests** (34 tests): Tab navigation, CRUD flows, empty states, screenshots

Run tests with `Cmd+U` in Xcode or:
```bash
xcodebuild test -scheme MeetAndGreet -destination 'platform=iOS Simulator,name=iPhone 8'
```

---

# iOS開発初心者向け：コード解説

以下では、iOSアプリ開発に慣れていない方向けに、このアプリの主要なコード構造を解説します。

## 1. アプリの起動（MeetAndGreetApp.swift）

```swift
@main
struct MeetAndGreetApp: App {
    let coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.viewContext)
        }
    }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| `@main` | アプリのエントリーポイント（起動時に最初に実行される場所） |
| `App`プロトコル | SwiftUIアプリの基本構造を定義 |
| `CoreDataStack.shared` | データ保存機能のシングルトン（アプリ全体で1つだけ存在） |
| `WindowGroup` | アプリのメインウィンドウを定義 |
| `.environment(...)` | 子ビュー全体でCore Dataのコンテキストを共有 |

**ポイント**: SwiftUIアプリは`@main`から始まり、`App`プロトコルに準拠した構造体がアプリ全体を管理します。

---

## 2. メイン画面（ContentView.swift）

```swift
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleListView()
                .tabItem {
                    Label("スケジュール", systemImage: "calendar")
                }
                .tag(0)

            BudgetView()
                .tabItem {
                    Label("家計簿", systemImage: "yensign.circle")
                }
                .tag(1)
            // ... 他のタブも同様
        }
        .accentColor(.pink)
    }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| `View`プロトコル | SwiftUIの画面（UI）を定義する基本単位 |
| `@Environment` | 親から渡された環境値を受け取る |
| `@State` | その画面内で変化する値を管理 |
| `TabView` | 下部にタブバーを持つ画面構造 |
| `$selectedTab` | `@State`変数への双方向バインディング |

**ポイント**: `@State`で状態を管理し、`$`をつけると双方向バインディング（値の読み書き両方）ができます。

---

## 3. データ保存の仕組み（CoreDataStack.swift）

```swift
class CoreDataStack {
    static let shared = CoreDataStack()  // シングルトン

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "MeetAndGreet",
            managedObjectModel: Self.managedObjectModel
        )
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| シングルトン | `static let shared`でアプリ全体で1つのインスタンスを共有 |
| `lazy var` | 最初にアクセスされた時に初期化される変数 |
| `NSPersistentContainer` | Core Dataの「箱」。データベースとの接続を管理 |
| `NSManagedObjectContext` | データの読み書きを行う「作業エリア」 |
| `saveContext()` | 変更をディスクに保存 |

**ポイント**: Core Dataは「コンテキスト」上でデータを操作し、明示的に`save()`を呼ぶまでディスクには保存されません。

---

## 4. データモデル（Entities.swift）

```swift
// エンティティ（データの型）の定義
@objc(ScheduleEntity)
public class ScheduleEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var eventDate: Date?
    @NSManaged public var isCompleted: Bool
}

// ヘルパーメソッドの追加
extension ScheduleEntity {
    // 新しいエンティティを作成
    static func create(in context: NSManagedObjectContext) -> ScheduleEntity {
        let entity = ScheduleEntity(context: context)
        entity.id = UUID()
        entity.title = ""
        entity.eventDate = Date()
        return entity
    }

    // Optionalを安全にアンラップするプロパティ
    var wrappedTitle: String { title ?? "" }
    var wrappedEventDate: Date { eventDate ?? Date() }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| `NSManagedObject` | Core Dataで管理されるデータの基底クラス |
| `@NSManaged` | Core Dataが自動的に値を管理することを示す |
| `Optional型（?）` | 値がnullになりうる場合に使用 |
| `wrapped*`プロパティ | Optionalを安全にアンラップするヘルパー |

**ポイント**: `??`演算子（nil合体演算子）で、nilの場合のデフォルト値を指定できます。

---

## 5. データの取得と表示（ScheduleListView.swift）

```swift
struct ScheduleListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Core Dataから自動的にデータを取得
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScheduleEntity.eventDate, ascending: true)],
        animation: .default
    ) private var schedules: FetchedResults<ScheduleEntity>

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(schedules, id: \.self) { schedule in
                    NavigationLink(destination: ScheduleDetailView(schedule: schedule)) {
                        ScheduleRowView(schedule: schedule)
                    }
                }
            }
            .navigationTitle("スケジュール")
        }
    }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| `@FetchRequest` | Core Dataからデータを自動取得・更新 |
| `sortDescriptors` | データの並び順を指定 |
| `FetchedResults` | 取得されたデータ配列（変更時に自動更新） |
| `NavigationView` | 画面遷移機能を持つコンテナ |
| `NavigationLink` | タップで別画面に遷移するリンク |
| `ForEach` | 配列の各要素に対してビューを生成 |

**ポイント**: `@FetchRequest`を使うと、データベースの変更が自動的にUIに反映されます。

---

## 6. フォーム入力（ExpenseEditorView.swift）

```swift
struct ExpenseEditorView: View {
    @Environment(\.presentationMode) var presentationMode  // モーダルを閉じる用

    @State private var title = ""
    @State private var amount = ""
    @State private var category = ExpenseCategory.ticket

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("項目名", text: $title)

                    HStack {
                        Text("¥")
                        TextField("金額", text: $amount)
                            .keyboardType(.numberPad)
                    }

                    Picker("カテゴリ", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func save() {
        // データを保存する処理
    }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| `Form` | 設定画面のようなフォームUI |
| `Section` | フォーム内のグループ分け |
| `TextField` | テキスト入力欄 |
| `Picker` | 選択肢から1つを選ぶUI |
| `presentationMode` | モーダル画面を閉じるためのハンドル |
| `.toolbar` | ナビゲーションバーにボタンを追加 |

**ポイント**: SwiftUIの`Form`は自動的にiOSらしいUI（グループ化、余白など）を適用してくれます。

---

## 7. 音声合成（TtsService.swift）

```swift
final class TtsService: NSObject, ObservableObject {
    static let shared = TtsService()  // シングルトン

    private let synthesizer = AVSpeechSynthesizer()

    @Published var isSpeaking: Bool = false  // UIに自動反映

    func speak(_ text: String, completion: (() -> Void)? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| `ObservableObject` | SwiftUIで監視可能なオブジェクト |
| `@Published` | 値が変わるとUIが自動更新される |
| `AVSpeechSynthesizer` | iOS標準の音声合成エンジン |
| `AVSpeechUtterance` | 読み上げテキストと設定を保持 |
| `language: "ja-JP"` | 日本語の音声を指定 |

**ポイント**: `@Published`と`ObservableObject`で、サービスの状態変化をUIに自動反映できます。

---

## 8. カスタムスタイル（AppTheme.swift）

```swift
// テーマの定義
struct AppTheme {
    let primaryColor: Color
    let cornerRadius: CGFloat

    static let apple = AppTheme(primaryColor: .blue, cornerRadius: 12)
    static let game = AppTheme(primaryColor: .pink, cornerRadius: 20)
}

// ViewModifier: 再利用可能なスタイル
struct ThemedCardModifier: ViewModifier {
    @Environment(\.appTheme) private var theme

    func body(content: Content) -> some View {
        content
            .background(theme.surfaceColor)
            .cornerRadius(theme.cornerRadius)
    }
}

// 簡単に使えるようにextension
extension View {
    func themedCard() -> some View {
        modifier(ThemedCardModifier())
    }
}
```

### 解説

| 要素 | 説明 |
|------|------|
| `ViewModifier` | 複数のビューに同じスタイルを適用 |
| `@Environment` | カスタム環境値からテーマを取得 |
| `extension View` | すべてのViewに新しいメソッドを追加 |

**使い方**:
```swift
Text("Hello")
    .themedCard()  // カードスタイルを適用
```

---

## よく使うSwiftUI用語

| 用語 | 説明 |
|------|------|
| `@State` | そのビュー内で管理する状態変数 |
| `@Binding` | 親ビューの状態への参照（双方向） |
| `@Environment` | アプリ全体で共有される値へのアクセス |
| `@FetchRequest` | Core Dataから自動でデータ取得 |
| `@Published` | 変更時にUIを更新する変数 |
| `@ObservedObject` | ObservableObjectを監視 |
| `$変数名` | バインディング（双方向接続） |

---

## データフロー図

```
┌─────────────────────────────────────────────────────────┐
│                    MeetAndGreetApp                       │
│  ┌──────────────────────────────────────────────────┐   │
│  │     CoreDataStack.shared (シングルトン)           │   │
│  │  ┌────────────────────────────────────────────┐  │   │
│  │  │ NSPersistentContainer (データベース接続)    │  │   │
│  │  │ viewContext (作業エリア)                   │  │   │
│  │  └────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────┘   │
│                           │                              │
│                    .environment()                        │
│                           ↓                              │
│  ┌──────────────────────────────────────────────────┐   │
│  │               ContentView (TabView)               │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐    │   │
│  │  │ Schedule   │ │ Budget     │ │ Practice   │    │   │
│  │  │ ListView   │ │ View       │ │ ListView   │    │   │
│  │  │            │ │            │ │            │    │   │
│  │  │@FetchRequest @FetchRequest @FetchRequest      │   │
│  │  └────────────┘ └────────────┘ └────────────┘    │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## License

MIT License

## Author

Created with assistance from Claude Code.
