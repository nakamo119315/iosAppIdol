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

### Practice (リハーサル)
- Conversation script creation for fan events
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
│   ├── Practice/              # Rehearsal views with TTS
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

## License

MIT License

## Author

Created with assistance from Claude Code.
