import CoreData

// MARK: - Schedule Entity
@objc(ScheduleEntity)
public class ScheduleEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var eventDescription: String?
    @NSManaged public var eventDate: Date?
    @NSManaged public var location: String?
    @NSManaged public var category: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var notes: String?
    @NSManaged public var ticketDeadline: Date?
    @NSManaged public var paymentDeadline: Date?
    @NSManaged public var createdAt: Date?
}

extension ScheduleEntity {
    static func create(in context: NSManagedObjectContext) -> ScheduleEntity {
        let entity = ScheduleEntity(context: context)
        entity.id = UUID()
        entity.title = ""
        entity.eventDescription = ""
        entity.eventDate = Date()
        entity.location = ""
        entity.category = "ライブ"
        entity.isCompleted = false
        entity.notes = ""
        entity.createdAt = Date()
        return entity
    }

    var wrappedTitle: String { title ?? "" }
    var wrappedLocation: String { location ?? "" }
    var wrappedCategory: String { category ?? "ライブ" }
    var wrappedEventDate: Date { eventDate ?? Date() }
    var wrappedNotes: String { notes ?? "" }
    var wrappedEventDescription: String { eventDescription ?? "" }
}

// MARK: - Expense Entity
@objc(ExpenseEntity)
public class ExpenseEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var amount: Int32
    @NSManaged public var category: String?
    @NSManaged public var expenseDate: Date?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var isPaid: Bool
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
}

extension ExpenseEntity {
    static func create(in context: NSManagedObjectContext) -> ExpenseEntity {
        let entity = ExpenseEntity(context: context)
        entity.id = UUID()
        entity.title = ""
        entity.amount = 0
        entity.category = "チケット"
        entity.expenseDate = Date()
        entity.paymentMethod = "現金"
        entity.isPaid = false
        entity.notes = ""
        entity.createdAt = Date()
        return entity
    }

    var wrappedTitle: String { title ?? "" }
    var wrappedCategory: String { category ?? "チケット" }
    var wrappedPaymentMethod: String { paymentMethod ?? "現金" }
    var wrappedExpenseDate: Date { expenseDate ?? Date() }
    var wrappedNotes: String { notes ?? "" }
}

// MARK: - PracticeScript Entity
@objc(PracticeScriptEntity)
public class PracticeScriptEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var scriptDescription: String?
    @NSManaged public var eventType: String?
    @NSManaged public var practiceCount: Int32
    @NSManaged public var lastPracticedAt: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var dialogues: NSSet?
}

extension PracticeScriptEntity {
    static func create(in context: NSManagedObjectContext) -> PracticeScriptEntity {
        let entity = PracticeScriptEntity(context: context)
        entity.id = UUID()
        entity.title = ""
        entity.scriptDescription = ""
        entity.eventType = "接触イベント"
        entity.practiceCount = 0
        entity.isFavorite = false
        entity.createdAt = Date()
        return entity
    }

    var wrappedTitle: String { title ?? "" }
    var wrappedEventType: String { eventType ?? "接触イベント" }
    var wrappedScriptDescription: String { scriptDescription ?? "" }

    var dialoguesArray: [PracticeDialogueEntity] {
        let set = dialogues as? Set<PracticeDialogueEntity> ?? []
        return set.sorted { $0.order < $1.order }
    }
}

// MARK: - PracticeDialogue Entity
@objc(PracticeDialogueEntity)
public class PracticeDialogueEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var content: String?
    @NSManaged public var speakerType: String?
    @NSManaged public var order: Int32
    @NSManaged public var notes: String?
    @NSManaged public var script: PracticeScriptEntity?
}

extension PracticeDialogueEntity {
    static func create(in context: NSManagedObjectContext, script: PracticeScriptEntity) -> PracticeDialogueEntity {
        let entity = PracticeDialogueEntity(context: context)
        entity.id = UUID()
        entity.content = ""
        entity.speakerType = "user"
        entity.order = 0
        entity.notes = ""
        entity.script = script
        return entity
    }

    var wrappedContent: String { content ?? "" }
    var wrappedSpeakerType: String { speakerType ?? "user" }
    var wrappedNotes: String { notes ?? "" }
    var isUserSpeaker: Bool { wrappedSpeakerType == "user" }
}

// MARK: - Report Entity
@objc(ReportEntity)
public class ReportEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var eventDate: Date?
    @NSManaged public var eventName: String?
    @NSManaged public var location: String?
    @NSManaged public var rating: Int32
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var messages: NSSet?
}

extension ReportEntity {
    static func create(in context: NSManagedObjectContext) -> ReportEntity {
        let entity = ReportEntity(context: context)
        entity.id = UUID()
        entity.title = ""
        entity.eventDate = Date()
        entity.eventName = ""
        entity.location = ""
        entity.rating = 5
        entity.notes = ""
        entity.createdAt = Date()
        return entity
    }

    var wrappedTitle: String { title ?? "" }
    var wrappedEventName: String { eventName ?? "" }
    var wrappedLocation: String { location ?? "" }
    var wrappedEventDate: Date { eventDate ?? Date() }
    var wrappedNotes: String { notes ?? "" }

    var messagesArray: [ChatMessageEntity] {
        let set = messages as? Set<ChatMessageEntity> ?? []
        return set.sorted { $0.order < $1.order }
    }
}

// MARK: - ChatMessage Entity
@objc(ChatMessageEntity)
public class ChatMessageEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var content: String?
    @NSManaged public var messageType: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var order: Int32
    @NSManaged public var report: ReportEntity?
}

extension ChatMessageEntity {
    static func create(in context: NSManagedObjectContext, report: ReportEntity) -> ChatMessageEntity {
        let entity = ChatMessageEntity(context: context)
        entity.id = UUID()
        entity.content = ""
        entity.messageType = "user"
        entity.timestamp = Date()
        entity.order = 0
        entity.report = report
        return entity
    }

    var wrappedContent: String { content ?? "" }
    var wrappedMessageType: String { messageType ?? "user" }
    var isUserMessage: Bool { wrappedMessageType == "user" }
}

// MARK: - UiSettings Entity
@objc(UiSettingsEntity)
public class UiSettingsEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var themeRawValue: String?
    @NSManaged public var ttsRate: Float
    @NSManaged public var ttsPitch: Float
    @NSManaged public var ttsVolume: Float
    @NSManaged public var animationsEnabled: Bool
}

extension UiSettingsEntity {
    static func create(in context: NSManagedObjectContext) -> UiSettingsEntity {
        let entity = UiSettingsEntity(context: context)
        entity.id = UUID()
        entity.themeRawValue = "apple"
        entity.ttsRate = 0.5
        entity.ttsPitch = 1.0
        entity.ttsVolume = 1.0
        entity.animationsEnabled = true
        return entity
    }

    var wrappedTheme: String { themeRawValue ?? "apple" }
    var isAppleTheme: Bool { wrappedTheme == "apple" }
}

// MARK: - Enums
enum EventCategory: String, CaseIterable {
    case live = "ライブ"
    case meetAndGreet = "接触イベント"
    case release = "リリイベ"
    case festival = "フェス"
    case fanMeeting = "ファンミ"
    case other = "その他"

    var icon: String {
        switch self {
        case .live: return "music.mic"
        case .meetAndGreet: return "hand.wave"
        case .release: return "music.note"
        case .festival: return "sparkles"
        case .fanMeeting: return "person.3"
        case .other: return "star"
        }
    }
}

enum ExpenseCategory: String, CaseIterable {
    case ticket = "チケット"
    case transportation = "交通費"
    case accommodation = "宿泊"
    case goods = "グッズ"
    case food = "食費"
    case gift = "プレゼント"
    case other = "その他"

    var icon: String {
        switch self {
        case .ticket: return "ticket"
        case .transportation: return "tram"
        case .accommodation: return "bed.double"
        case .goods: return "bag"
        case .food: return "fork.knife"
        case .gift: return "gift"
        case .other: return "ellipsis.circle"
        }
    }
}

enum PaymentMethod: String, CaseIterable {
    case cash = "現金"
    case creditCard = "クレジットカード"
    case electronicMoney = "電子マネー"
    case bankTransfer = "振込"
    case other = "その他"
}

enum PracticeEventType: String, CaseIterable {
    case meetAndGreet = "接触イベント"
    case handshake = "握手会"
    case photoSession = "撮影会"
    case signing = "サイン会"
    case talkEvent = "トークイベント"
    case other = "その他"

    var icon: String {
        switch self {
        case .meetAndGreet: return "hand.wave"
        case .handshake: return "hand.raised"
        case .photoSession: return "camera"
        case .signing: return "pencil"
        case .talkEvent: return "bubble.left.and.bubble.right"
        case .other: return "star"
        }
    }
}

// MARK: - Date Formatting (iOS 14 compatible)
extension Date {
    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    private static let shortDateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    private static let fullDateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    var shortDate: String { Date.shortDateFormatter.string(from: self) }
    var shortDateTime: String { Date.shortDateTimeFormatter.string(from: self) }
    var fullDate: String { Date.fullDateFormatter.string(from: self) }
    var fullDateTime: String { Date.fullDateTimeFormatter.string(from: self) }
}

// MARK: - Number Formatting
extension Int {
    var withComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Int32 {
    var withComma: String { Int(self).withComma }
}
