import SwiftUI
import CoreData

struct PracticeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PracticeScriptEntity.createdAt, ascending: false)],
        animation: .default
    ) private var scripts: FetchedResults<PracticeScriptEntity>

    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            Group {
                if scripts.isEmpty {
                    emptyState
                } else {
                    scriptList
                }
            }
            .navigationTitle("会話練習")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ScriptEditorView(script: nil)
            }
        }
    }

    private var scriptList: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("シナリオをタップして練習を開始できます")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("会話シナリオ")) {
                ForEach(scripts, id: \.self) { script in
                    NavigationLink(destination: PracticeDetailView(script: script)) {
                        ScriptRowView(script: script)
                    }
                }
                .onDelete(perform: deleteScripts)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink.opacity(0.6))

            VStack(spacing: 8) {
                Text("推しとの会話を練習しよう")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("接触イベントで何を話すか迷ったことはありませんか？\n会話シナリオを作成して、事前にシミュレーションできます")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "pencil.and.outline", text: "伝えたいセリフを書き出す")
                FeatureRow(icon: "speaker.wave.2.fill", text: "推しのセリフは音声で再生")
                FeatureRow(icon: "arrow.counterclockwise", text: "何度でも繰り返し練習")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            Button(action: { showingAddSheet = true }) {
                Label("シナリオを作成", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }

    private func deleteScripts(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(scripts[index])
        }
        CoreDataStack.shared.saveContext()
    }
}

struct ScriptRowView: View {
    let script: PracticeScriptEntity

    private var eventType: PracticeEventType {
        PracticeEventType(rawValue: script.wrappedEventType) ?? .other
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: eventType.icon)
                    .foregroundColor(.pink)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(script.wrappedTitle)
                        .font(.headline)

                    if script.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }

                HStack(spacing: 8) {
                    Text(eventType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(script.dialoguesArray.count)セリフ")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if script.practiceCount > 0 {
                        Text("\(script.practiceCount)回練習")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct PracticeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var script: PracticeScriptEntity
    @FetchRequest private var dialogues: FetchedResults<PracticeDialogueEntity>

    @State private var showingEditSheet = false
    @State private var showingPlayer = false

    init(script: PracticeScriptEntity) {
        self._script = ObservedObject(wrappedValue: script)
        self._dialogues = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \PracticeDialogueEntity.order, ascending: true)],
            predicate: NSPredicate(format: "script == %@", script)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        let eventType = PracticeEventType(rawValue: script.wrappedEventType) ?? .other
                        Label(eventType.rawValue, systemImage: eventType.icon)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.pink.opacity(0.2))
                            .foregroundColor(.pink)
                            .cornerRadius(12)

                        Spacer()

                        if script.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }

                    Text(script.wrappedTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !script.wrappedScriptDescription.isEmpty {
                        Text(script.wrappedScriptDescription)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Stats
                HStack {
                    StatView(title: "セリフ数", value: "\(dialogues.count)", icon: "text.bubble")
                    Divider().frame(height: 40)
                    StatView(title: "練習回数", value: "\(script.practiceCount)", icon: "arrow.counterclockwise")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Dialogues
                VStack(alignment: .leading, spacing: 12) {
                    Text("会話の流れ")
                        .font(.headline)

                    ForEach(Array(dialogues.enumerated()), id: \.element) { index, dialogue in
                        DialoguePreviewRow(index: index + 1, dialogue: dialogue)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Start button
                Button(action: { showingPlayer = true }) {
                    Label("練習を開始", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("シナリオ詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("編集", systemImage: "pencil")
                    }
                    Button(action: {
                        script.isFavorite.toggle()
                        CoreDataStack.shared.saveContext()
                    }) {
                        Label(script.isFavorite ? "お気に入り解除" : "お気に入り", systemImage: "star")
                    }
                    Button(action: {
                        viewContext.delete(script)
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
            ScriptEditorView(script: script)
        }
        .fullScreenCover(isPresented: $showingPlayer) {
            PracticePlayerView(script: script)
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.pink)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DialoguePreviewRow: View {
    let index: Int
    let dialogue: PracticeDialogueEntity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(dialogue.isUserSpeaker ? Color.gray : Color.pink)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(dialogue.isUserSpeaker ? "自分" : "推し")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(dialogue.isUserSpeaker ? .gray : .pink)

                Text(dialogue.wrappedContent)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ScriptEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var script: PracticeScriptEntity?

    @State private var title = ""
    @State private var scriptDescription = ""
    @State private var eventType = PracticeEventType.meetAndGreet
    @State private var dialogues: [DialogueItem] = []

    struct DialogueItem: Identifiable {
        let id = UUID()
        var content: String
        var isUser: Bool
    }

    var body: some View {
        NavigationView {
            Form {
                if script == nil {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("会話シナリオの作り方")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("1. 推しに言いたいことを「自分」に入力\n2. 予想される返答を「推し」に入力\n3. 練習では推しのセリフが音声で再生されます")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Text("基本情報")) {
                    TextField("タイトル（例：握手会の挨拶）", text: $title)

                    Picker("イベントタイプ", selection: $eventType) {
                        ForEach(PracticeEventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }

                    TextField("メモ（任意）", text: $scriptDescription)
                }

                Section(header: Text("会話の流れ"), footer: Text("「推し」のセリフは練習時に音声で再生されます")) {
                    ForEach(dialogues.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("話者", selection: $dialogues[index].isUser) {
                                Text("自分").tag(true)
                                Text("推し").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())

                            TextField("セリフを入力...", text: $dialogues[index].content)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        dialogues.remove(atOffsets: offsets)
                    }

                    HStack {
                        Button(action: { dialogues.append(DialogueItem(content: "", isUser: true)) }) {
                            Label("自分を追加", systemImage: "plus.circle")
                        }
                        Spacer()
                        Button(action: { dialogues.append(DialogueItem(content: "", isUser: false)) }) {
                            Label("推しを追加", systemImage: "plus.circle.fill")
                                .foregroundColor(.pink)
                        }
                    }
                    .font(.subheadline)
                }
            }
            .navigationTitle(script == nil ? "新しいシナリオ" : "シナリオ編集")
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
                if let script = script {
                    title = script.wrappedTitle
                    scriptDescription = script.wrappedScriptDescription
                    eventType = PracticeEventType(rawValue: script.wrappedEventType) ?? .meetAndGreet
                    dialogues = script.dialoguesArray.map {
                        DialogueItem(content: $0.wrappedContent, isUser: $0.isUserSpeaker)
                    }
                } else {
                    dialogues = [
                        DialogueItem(content: "", isUser: false),
                        DialogueItem(content: "", isUser: true)
                    ]
                }
            }
        }
    }

    private func save() {
        let entity = script ?? PracticeScriptEntity.create(in: viewContext)
        entity.title = title
        entity.scriptDescription = scriptDescription
        entity.eventType = eventType.rawValue

        // Delete existing dialogues
        for dialogue in entity.dialoguesArray {
            viewContext.delete(dialogue)
        }

        // Add new dialogues
        for (index, item) in dialogues.enumerated() where !item.content.isEmpty {
            let dialogue = PracticeDialogueEntity.create(in: viewContext, script: entity)
            dialogue.content = item.content
            dialogue.speakerType = item.isUser ? "user" : "oshi"
            dialogue.order = Int32(index)
        }

        CoreDataStack.shared.saveContext()
    }
}

struct PracticePlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var script: PracticeScriptEntity
    @StateObject private var ttsService = TtsService.shared

    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var isCompleted = false

    private var dialogues: [PracticeDialogueEntity] {
        script.dialoguesArray
    }

    private var currentDialogue: PracticeDialogueEntity? {
        guard currentIndex < dialogues.count else { return nil }
        return dialogues[currentIndex]
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                    }
                    Spacer()
                    Text("\(currentIndex + 1) / \(dialogues.count)")
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 28)
                }
                .padding()

                // Progress
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color(.systemGray5))
                        Rectangle()
                            .fill(Color.pink)
                            .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(max(dialogues.count, 1)))
                    }
                }
                .frame(height: 4)

                Spacer()

                // Content
                if isCompleted {
                    completionView
                } else if let dialogue = currentDialogue {
                    dialogueView(dialogue)
                }

                Spacer()

                // Controls
                if !isCompleted {
                    HStack(spacing: 32) {
                        Button(action: skip) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }

                        Button(action: togglePlay) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.pink)
                                .frame(width: 60, height: 60)
                                .background(Color.pink.opacity(0.2))
                                .clipShape(Circle())
                        }

                        Button(action: reset) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                }
            }
        }
    }

    private func dialogueView(_ dialogue: PracticeDialogueEntity) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill((dialogue.isUserSpeaker ? Color.gray : Color.pink).opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: dialogue.isUserSpeaker ? "person.fill" : "star.fill")
                    .font(.system(size: 36))
                    .foregroundColor(dialogue.isUserSpeaker ? .gray : .pink)
            }

            Text(dialogue.isUserSpeaker ? "自分" : "推し")
                .font(.headline)
                .foregroundColor(dialogue.isUserSpeaker ? .gray : .pink)

            Text(dialogue.wrappedContent)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("練習完了！")
                .font(.title)
                .fontWeight(.bold)

            Text("お疲れさまでした")
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Button(action: {
                    reset()
                    isCompleted = false
                }) {
                    Label("もう一度", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(12)

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("終了")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }

    private func togglePlay() {
        if isPlaying {
            ttsService.stop()
            isPlaying = false
        } else {
            playCurrentDialogue()
        }
    }

    private func playCurrentDialogue() {
        guard let dialogue = currentDialogue else {
            finish()
            return
        }

        isPlaying = true

        if !dialogue.isUserSpeaker {
            ttsService.speak(dialogue.wrappedContent) { [self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    moveToNext()
                }
            }
        }
    }

    private func moveToNext() {
        if currentIndex < dialogues.count - 1 {
            currentIndex += 1
            playCurrentDialogue()
        } else {
            finish()
        }
    }

    private func skip() {
        ttsService.stop()
        moveToNext()
    }

    private func reset() {
        ttsService.stop()
        currentIndex = 0
        isPlaying = false
    }

    private func finish() {
        isPlaying = false
        isCompleted = true
        script.practiceCount += 1
        script.lastPracticedAt = Date()
        CoreDataStack.shared.saveContext()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct PracticeListView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeListView()
            .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
    }
}
