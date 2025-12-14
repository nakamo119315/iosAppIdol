import SwiftUI
import CoreData

struct ReportListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ReportEntity.eventDate, ascending: false)],
        animation: .default
    ) private var reports: FetchedResults<ReportEntity>

    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            Group {
                if reports.isEmpty {
                    emptyState
                } else {
                    reportList
                }
            }
            .navigationTitle("レポ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ReportEditorView(report: nil)
            }
        }
    }

    private var reportList: some View {
        List {
            ForEach(reports, id: \.self) { report in
                NavigationLink(destination: ReportDetailView(report: report)) {
                    ReportRowView(report: report)
                }
            }
            .onDelete(perform: deleteReports)
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("レポートがありません")
                .font(.headline)

            Text("思い出を記録しましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("レポートを作成") {
                showingAddSheet = true
            }
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }

    private func deleteReports(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(reports[index])
        }
        CoreDataStack.shared.saveContext()
    }
}

struct ReportRowView: View {
    let report: ReportEntity

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 44, height: 44)

                Text("★")
                    .font(.title2)
                    .foregroundColor(.pink)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(report.wrappedTitle)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(report.wrappedEventName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text(report.wrappedEventDate.shortDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < report.rating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ReportDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var report: ReportEntity
    @State private var showingEditSheet = false
    @State private var showingMessageInput = false
    @State private var newMessageText = ""
    @State private var isUserMessage = true
    @State private var editingMessage: ChatMessageEntity?
    @State private var editingMessageText = ""
    @State private var showingMessageEditor = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Text(report.wrappedTitle)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: index < report.rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }

                        HStack(spacing: 12) {
                            Label(report.wrappedEventName, systemImage: "music.mic")
                            Label(report.wrappedEventDate.shortDate, systemImage: "calendar")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                    // Notes section (before chat)
                    if !report.wrappedNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.orange)
                                Text("メモ")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }

                            Text(report.wrappedNotes)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }

                    // Chat section header
                    if !report.messagesArray.isEmpty {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .foregroundColor(.gray)
                            Text("会話ログ")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }

                    // Chat messages
                    ForEach(report.messagesArray, id: \.self) { message in
                        ChatBubbleView(message: message)
                            .contextMenu {
                                Button(action: {
                                    editingMessageText = message.wrappedContent
                                    editingMessage = message
                                    showingMessageEditor = true
                                }) {
                                    Label("編集", systemImage: "pencil")
                                }
                                Button(action: {
                                    viewContext.delete(message)
                                    CoreDataStack.shared.saveContext()
                                }) {
                                    Label("削除", systemImage: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                    }
                }
                .padding()
            }

            // Message input
            VStack(spacing: 8) {
                Divider()

                // Speaker toggle
                HStack(spacing: 12) {
                    Text("話者:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: { isUserMessage = true }) {
                        Text("自分")
                            .font(.caption)
                            .fontWeight(isUserMessage ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isUserMessage ? Color.pink : Color(.secondarySystemBackground))
                            .foregroundColor(isUserMessage ? .white : .primary)
                            .cornerRadius(12)
                    }

                    Button(action: { isUserMessage = false }) {
                        Text("推し")
                            .font(.caption)
                            .fontWeight(!isUserMessage ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(!isUserMessage ? Color.purple : Color(.secondarySystemBackground))
                            .foregroundColor(!isUserMessage ? .white : .primary)
                            .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                HStack {
                    TextField("メッセージを追加...", text: $newMessageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: addMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(isUserMessage ? .pink : .purple)
                    }
                    .disabled(newMessageText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("レポート詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("編集", systemImage: "pencil")
                    }
                    Button(action: {
                        viewContext.delete(report)
                        CoreDataStack.shared.saveContext()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("削除", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ReportEditorView(report: report)
        }
        .sheet(isPresented: $showingMessageEditor) {
            if let message = editingMessage {
                MessageEditorSheet(message: message, messageText: editingMessageText, report: report)
            }
        }
    }

    private func addMessage() {
        guard !newMessageText.isEmpty else { return }

        let message = ChatMessageEntity.create(in: viewContext, report: report)
        message.content = newMessageText
        message.messageType = isUserMessage ? "user" : "oshi"
        message.order = Int32(report.messagesArray.count)

        newMessageText = ""
        CoreDataStack.shared.saveContext()
    }
}

struct ChatBubbleView: View {
    let message: ChatMessageEntity

    var body: some View {
        HStack {
            if message.isUserMessage {
                Spacer()
            }

            Text(message.wrappedContent)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isUserMessage ? Color.pink : Color.purple)
                .foregroundColor(.white)
                .cornerRadius(16)

            if !message.isUserMessage {
                Spacer()
            }
        }
    }
}

struct MessageEditorSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var message: ChatMessageEntity
    @ObservedObject var report: ReportEntity
    @State var messageText: String
    @State private var isUserSpeaker: Bool = true

    init(message: ChatMessageEntity, messageText: String, report: ReportEntity) {
        self.message = message
        self.report = report
        self._messageText = State(initialValue: messageText)
        self._isUserSpeaker = State(initialValue: message.isUserMessage)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("メッセージ")) {
                    TextEditor(text: $messageText)
                        .frame(minHeight: 100)
                }

                Section(header: Text("話者")) {
                    Picker("話者", selection: $isUserSpeaker) {
                        Text("自分").tag(true)
                        Text("推し").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("メッセージ編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        message.content = messageText
                        message.messageType = isUserSpeaker ? "user" : "oshi"
                        CoreDataStack.shared.saveContext()
                        report.objectWillChange.send()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(messageText.isEmpty)
                }
            }
        }
    }
}

struct ReportEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var report: ReportEntity?

    @State private var title = ""
    @State private var eventName = ""
    @State private var eventDate = Date()
    @State private var location = ""
    @State private var rating: Int32 = 5
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("タイトル", text: $title)
                    TextField("イベント名", text: $eventName)
                    DatePicker("日付", selection: $eventDate, displayedComponents: .date)
                    TextField("場所", text: $location)
                }

                Section(header: Text("評価")) {
                    HStack {
                        Text("満足度")
                        Spacer()
                        ForEach(1...5, id: \.self) { index in
                            Button(action: { rating = Int32(index) }) {
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                Section(header: Text("メモ")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(report == nil ? "新規レポート" : "レポート編集")
            .navigationBarTitleDisplayMode(.inline)
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
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let report = report {
                    title = report.wrappedTitle
                    eventName = report.wrappedEventName
                    eventDate = report.wrappedEventDate
                    location = report.wrappedLocation
                    rating = report.rating
                    notes = report.wrappedNotes
                }
            }
        }
    }

    private func save() {
        let entity = report ?? ReportEntity.create(in: viewContext)
        entity.title = title
        entity.eventName = eventName
        entity.eventDate = eventDate
        entity.location = location
        entity.rating = rating
        entity.notes = notes
        CoreDataStack.shared.saveContext()
    }
}

struct ReportListView_Previews: PreviewProvider {
    static var previews: some View {
        ReportListView()
            .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
    }
}
