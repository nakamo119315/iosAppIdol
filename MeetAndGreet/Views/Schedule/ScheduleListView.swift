import SwiftUI
import CoreData

struct ScheduleListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScheduleEntity.eventDate, ascending: true)],
        animation: .default
    ) private var schedules: FetchedResults<ScheduleEntity>

    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            Group {
                if schedules.isEmpty {
                    emptyState
                } else {
                    scheduleList
                }
            }
            .navigationTitle("スケジュール")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ScheduleEditorView(schedule: nil)
            }
        }
    }

    private var scheduleList: some View {
        List {
            ForEach(schedules, id: \.self) { schedule in
                NavigationLink(destination: ScheduleDetailView(schedule: schedule)) {
                    ScheduleRowView(schedule: schedule)
                }
            }
            .onDelete(perform: deleteSchedules)
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("イベントがありません")
                .font(.headline)

            Text("右上の＋ボタンから新しいイベントを追加しましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("イベントを追加") {
                showingAddSheet = true
            }
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }

    private func deleteSchedules(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(schedules[index])
        }
        CoreDataStack.shared.saveContext()
    }
}

struct ScheduleRowView: View {
    let schedule: ScheduleEntity

    private var category: EventCategory {
        EventCategory(rawValue: schedule.wrappedCategory) ?? .other
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.forEventCategory(category).opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: category.icon)
                    .foregroundColor(Color.forEventCategory(category))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.wrappedTitle)
                    .font(.headline)
                    .strikethrough(schedule.isCompleted)

                HStack(spacing: 8) {
                    Text(schedule.wrappedEventDate.shortDateTime)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if !schedule.wrappedLocation.isEmpty {
                        Text(schedule.wrappedLocation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ScheduleDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var schedule: ScheduleEntity
    @State private var showingEditSheet = false

    private var category: EventCategory {
        EventCategory(rawValue: schedule.wrappedCategory) ?? .other
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Label(category.rawValue, systemImage: category.icon)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.forEventCategory(category).opacity(0.2))
                            .foregroundColor(Color.forEventCategory(category))
                            .cornerRadius(12)

                        Spacer()

                        if schedule.isCompleted {
                            Label("完了", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    Text(schedule.wrappedTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Date & Location
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.pink)
                        Text(schedule.wrappedEventDate.fullDateTime)
                        Spacer()
                    }

                    if !schedule.wrappedLocation.isEmpty {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.pink)
                            Text(schedule.wrappedLocation)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Notes
                if !schedule.wrappedNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メモ")
                            .font(.headline)
                        Text(schedule.wrappedNotes)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        schedule.isCompleted.toggle()
                        CoreDataStack.shared.saveContext()
                    }) {
                        Label(schedule.isCompleted ? "未完了に戻す" : "完了にする",
                              systemImage: schedule.isCompleted ? "arrow.uturn.backward" : "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button(action: {
                        viewContext.delete(schedule)
                        CoreDataStack.shared.saveContext()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("削除", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("イベント詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編集") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ScheduleEditorView(schedule: schedule)
        }
    }
}

struct ScheduleEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var schedule: ScheduleEntity?

    @State private var title = ""
    @State private var eventDate = Date()
    @State private var location = ""
    @State private var category = EventCategory.live
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("イベント名", text: $title)

                    Picker("カテゴリ", selection: $category) {
                        ForEach(EventCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }

                    DatePicker("日時", selection: $eventDate)

                    TextField("場所", text: $location)
                }

                Section(header: Text("メモ")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(schedule == nil ? "新規イベント" : "イベント編集")
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
                if let schedule = schedule {
                    title = schedule.wrappedTitle
                    eventDate = schedule.wrappedEventDate
                    location = schedule.wrappedLocation
                    category = EventCategory(rawValue: schedule.wrappedCategory) ?? .live
                    notes = schedule.wrappedNotes
                }
            }
        }
    }

    private func save() {
        let entity = schedule ?? ScheduleEntity.create(in: viewContext)
        entity.title = title
        entity.eventDate = eventDate
        entity.location = location
        entity.category = category.rawValue
        entity.notes = notes
        CoreDataStack.shared.saveContext()
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView()
            .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
    }
}
