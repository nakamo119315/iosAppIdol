import SwiftUI
import CoreData

struct ScheduleListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScheduleEntity.eventDate, ascending: true)],
        animation: .default
    ) private var schedules: FetchedResults<ScheduleEntity>

    @State private var showingAddSheet = false
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Calendar
                    CalendarView(
                        currentMonth: $currentMonth,
                        selectedDate: $selectedDate,
                        schedules: Array(schedules)
                    )

                    // Selected date events
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(selectedDate.fullDate)
                                .font(.headline)
                            Spacer()
                            Text("\(eventsForSelectedDate.count)件")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        if eventsForSelectedDate.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("この日のイベントはありません")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        } else {
                            ForEach(eventsForSelectedDate, id: \.self) { schedule in
                                NavigationLink(destination: ScheduleDetailView(schedule: schedule)) {
                                    ScheduleRowView(schedule: schedule)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Upcoming events
                    if !upcomingEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("今後のイベント")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(upcomingEvents.prefix(5), id: \.self) { schedule in
                                NavigationLink(destination: ScheduleDetailView(schedule: schedule)) {
                                    UpcomingEventRow(schedule: schedule)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical)
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

    private var eventsForSelectedDate: [ScheduleEntity] {
        schedules.filter { calendar.isDate($0.wrappedEventDate, inSameDayAs: selectedDate) }
    }

    private var upcomingEvents: [ScheduleEntity] {
        let today = calendar.startOfDay(for: Date())
        return schedules.filter { $0.wrappedEventDate >= today && !$0.isCompleted }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let schedules: [ScheduleEntity]

    private let calendar = Calendar.current
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.pink)
                }

                Spacer()

                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.pink)
                }
            }
            .padding(.horizontal)

            // Today button
            Button(action: goToToday) {
                Text("今日")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.2))
                    .foregroundColor(.pink)
                    .cornerRadius(8)
            }

            // Weekday header
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(day == "日" ? .red : (day == "土" ? .blue : .secondary))
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            eventCount: eventsCount(for: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        // Add empty cells for days before month starts
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        // Add days of month
        var date = firstDayOfMonth
        while date < monthInterval.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        return days
    }

    private func eventsCount(for date: Date) -> Int {
        schedules.filter { calendar.isDate($0.wrappedEventDate, inSameDayAs: date) }.count
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }

    private func goToToday() {
        currentMonth = Date()
        selectedDate = Date()
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventCount: Int

    private let calendar = Calendar.current

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    private var weekday: Int {
        calendar.component(.weekday, from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 32, height: 32)
                } else if isToday {
                    Circle()
                        .stroke(Color.pink, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }

                Text(dayNumber)
                    .font(.system(size: 14, weight: isSelected || isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : (weekday == 1 ? .red : (weekday == 7 ? .blue : .primary)))
            }

            // Event dots
            HStack(spacing: 2) {
                ForEach(0..<min(eventCount, 3), id: \.self) { _ in
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.8) : Color.pink)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 44)
    }
}

// MARK: - Upcoming Event Row
struct UpcomingEventRow: View {
    let schedule: ScheduleEntity

    private var category: EventCategory {
        EventCategory(rawValue: schedule.wrappedCategory) ?? .other
    }

    private var daysUntil: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let eventDay = calendar.startOfDay(for: schedule.wrappedEventDate)
        return calendar.dateComponents([.day], from: today, to: eventDay).day ?? 0
    }

    private var daysUntilText: String {
        if daysUntil == 0 { return "今日" }
        if daysUntil == 1 { return "明日" }
        return "\(daysUntil)日後"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Days until badge
            Text(daysUntilText)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(daysUntil <= 3 ? Color.orange : Color.gray)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(schedule.wrappedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(schedule.wrappedEventDate.shortDateTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: category.icon)
                .foregroundColor(Color.forEventCategory(category))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Schedule Row View
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
                    .frame(width: 40, height: 40)

                Image(systemName: category.icon)
                    .foregroundColor(Color.forEventCategory(category))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.wrappedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(schedule.isCompleted)
                    .foregroundColor(.primary)

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

            if schedule.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Schedule Detail View
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

// MARK: - Schedule Editor View
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
