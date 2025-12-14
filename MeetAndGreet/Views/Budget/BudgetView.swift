import SwiftUI
import CoreData

struct BudgetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExpenseEntity.expenseDate, ascending: false)],
        animation: .default
    ) private var expenses: FetchedResults<ExpenseEntity>

    @State private var showingAddSheet = false
    @State private var selectedChartTab = 0
    @State private var currentMonth = Date()

    private let calendar = Calendar.current

    private var expensesForMonth: [ExpenseEntity] {
        expenses.filter { expense in
            calendar.isDate(expense.wrappedExpenseDate, equalTo: currentMonth, toGranularity: .month)
        }
    }

    private var totalAmount: Int {
        expensesForMonth.reduce(0) { $0 + Int($1.amount) }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }

    var body: some View {
        NavigationView {
            ScrollView {
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
                            .font(.title3)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(.pink)
                        }
                    }
                    .padding(.horizontal, 24)

                    if !isCurrentMonth {
                        Button(action: goToCurrentMonth) {
                            Text("今月に戻る")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.2))
                                .foregroundColor(.pink)
                                .cornerRadius(8)
                        }
                    }

                    // Summary
                    VStack(spacing: 8) {
                        Text("¥\(totalAmount.withComma)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.pink)

                        Text("\(expensesForMonth.count)件")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    if !expensesForMonth.isEmpty {
                        // Chart section
                        VStack(spacing: 16) {
                            // Tab selector
                            Picker("グラフ", selection: $selectedChartTab) {
                                Text("カテゴリ").tag(0)
                                Text("支払い方法").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)

                            if selectedChartTab == 0 {
                                CategoryChartSection(expenses: expensesForMonth)
                            } else {
                                PaymentMethodChartSection(expenses: expensesForMonth)
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Expense list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("支出一覧")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(expensesForMonth, id: \.self) { expense in
                                NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                                    ExpenseRowView(expense: expense)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        emptyStateForMonth
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("家計簿")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ExpenseEditorView(expense: nil)
            }
        }
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }

    private func goToCurrentMonth() {
        currentMonth = Date()
    }

    private var emptyStateForMonth: some View {
        VStack(spacing: 16) {
            Image(systemName: "yensign.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("この月の支出はありません")
                .font(.headline)

            Text("右上の＋ボタンから支出を記録しましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("支出を追加") {
                showingAddSheet = true
            }
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Category Chart Section
struct CategoryChartSection: View {
    let expenses: [ExpenseEntity]

    private var categoryData: [(category: ExpenseCategory, amount: Int, percentage: Double)] {
        let total = expenses.reduce(0) { $0 + Int($1.amount) }
        guard total > 0 else { return [] }

        var data: [ExpenseCategory: Int] = [:]
        for expense in expenses {
            let category = ExpenseCategory(rawValue: expense.wrappedCategory) ?? .other
            data[category, default: 0] += Int(expense.amount)
        }

        return data.map { (category: $0.key, amount: $0.value, percentage: Double($0.value) / Double(total)) }
            .sorted { $0.amount > $1.amount }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Pie Chart
            PieChartView(data: categoryData.map { (Color.forExpenseCategory($0.category), $0.percentage) })
                .frame(height: 200)
                .padding(.horizontal)

            // Legend
            VStack(spacing: 8) {
                ForEach(categoryData, id: \.category) { item in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.forExpenseCategory(item.category))
                            .frame(width: 12, height: 12)

                        HStack(spacing: 4) {
                            Image(systemName: item.category.icon)
                                .font(.caption)
                            Text(item.category.rawValue)
                                .font(.subheadline)
                        }

                        Spacer()

                        Text("¥\(item.amount.withComma)")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(String(format: "%.1f%%", item.percentage * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Payment Method Chart Section
struct PaymentMethodChartSection: View {
    let expenses: [ExpenseEntity]

    private var paymentData: [(method: String, amount: Int, percentage: Double)] {
        let total = expenses.reduce(0) { $0 + Int($1.amount) }
        guard total > 0 else { return [] }

        var data: [String: Int] = [:]
        for expense in expenses {
            let method = expense.wrappedPaymentMethod
            data[method, default: 0] += Int(expense.amount)
        }

        return data.map { (method: $0.key, amount: $0.value, percentage: Double($0.value) / Double(total)) }
            .sorted { $0.amount > $1.amount }
    }

    private func colorForPaymentMethod(_ method: String) -> Color {
        switch method {
        case "現金": return .green
        case "クレジットカード": return .blue
        case "電子マネー": return .orange
        case "QRコード決済": return .purple
        case "銀行振込": return Color(red: 0.0, green: 0.5, blue: 0.5)
        default: return .gray
        }
    }

    private func iconForPaymentMethod(_ method: String) -> String {
        switch method {
        case "現金": return "banknote"
        case "クレジットカード": return "creditcard"
        case "電子マネー": return "wave.3.right"
        case "QRコード決済": return "qrcode"
        case "銀行振込": return "building.columns"
        default: return "questionmark.circle"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Bar Chart
            BarChartView(data: paymentData.map { (colorForPaymentMethod($0.method), $0.percentage, $0.method) })
                .frame(height: 180)
                .padding(.horizontal)

            // Legend
            VStack(spacing: 8) {
                ForEach(paymentData, id: \.method) { item in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(colorForPaymentMethod(item.method))
                            .frame(width: 12, height: 12)

                        HStack(spacing: 4) {
                            Image(systemName: iconForPaymentMethod(item.method))
                                .font(.caption)
                            Text(item.method)
                                .font(.subheadline)
                        }

                        Spacer()

                        Text("¥\(item.amount.withComma)")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(String(format: "%.1f%%", item.percentage * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Pie Chart View
struct PieChartView: View {
    let data: [(color: Color, percentage: Double)]

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2 - 10

            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index)
                    )
                    .fill(data[index].color)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
                }

                // Center circle (donut effect)
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: radius, height: radius)
                    .position(center)

                // Center text
                VStack(spacing: 2) {
                    Text("合計")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(data.count)件")
                        .font(.headline)
                }
                .position(center)
            }
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let sum = data.prefix(index).reduce(0) { $0 + $1.percentage }
        return Angle(degrees: sum * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let sum = data.prefix(index + 1).reduce(0) { $0 + $1.percentage }
        return Angle(degrees: sum * 360 - 90)
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Bar Chart View
struct BarChartView: View {
    let data: [(color: Color, percentage: Double, label: String)]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<data.count, id: \.self) { index in
                HStack(spacing: 8) {
                    Text(data[index].label)
                        .font(.caption)
                        .frame(width: 80, alignment: .leading)
                        .lineLimit(1)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 20)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(data[index].color)
                                .frame(width: max(geometry.size.width * CGFloat(data[index].percentage), 4), height: 20)
                        }
                    }
                    .frame(height: 20)

                    Text(String(format: "%.0f%%", data[index].percentage * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .trailing)
                }
            }
        }
    }
}

// MARK: - Expense Row View
struct ExpenseRowView: View {
    let expense: ExpenseEntity

    private var category: ExpenseCategory {
        ExpenseCategory(rawValue: expense.wrappedCategory) ?? .other
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.forExpenseCategory(category).opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: category.icon)
                    .foregroundColor(Color.forExpenseCategory(category))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.wrappedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text(category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(expense.wrappedExpenseDate.shortDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("¥\(expense.amount.withComma)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                if !expense.isPaid {
                    Text("未払い")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
        }
    }
}

// MARK: - Expense Detail View
struct ExpenseDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var expense: ExpenseEntity
    @State private var showingEditSheet = false

    private var category: ExpenseCategory {
        ExpenseCategory(rawValue: expense.wrappedCategory) ?? .other
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Amount header
                VStack(spacing: 12) {
                    Label(category.rawValue, systemImage: category.icon)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.forExpenseCategory(category).opacity(0.2))
                        .foregroundColor(Color.forExpenseCategory(category))
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(expense.wrappedTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("¥\(expense.amount.withComma)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Details
                VStack(spacing: 16) {
                    HStack {
                        Text("日付")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(expense.wrappedExpenseDate.fullDate)
                    }

                    Divider()

                    HStack {
                        Text("支払い方法")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(expense.wrappedPaymentMethod)
                    }

                    Divider()

                    HStack {
                        Text("支払い状況")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(expense.isPaid ? "支払い済み" : "未払い")
                            .foregroundColor(expense.isPaid ? .green : .orange)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        expense.isPaid.toggle()
                        CoreDataStack.shared.saveContext()
                    }) {
                        Label(expense.isPaid ? "未払いに戻す" : "支払い済みにする",
                              systemImage: expense.isPaid ? "arrow.uturn.backward" : "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button(action: {
                        viewContext.delete(expense)
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
        .navigationTitle("支出詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編集") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ExpenseEditorView(expense: expense)
        }
    }
}

// MARK: - Expense Editor View
struct ExpenseEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var expense: ExpenseEntity?

    @State private var title = ""
    @State private var amount = ""
    @State private var category = ExpenseCategory.ticket
    @State private var expenseDate = Date()
    @State private var paymentMethod = PaymentMethod.cash
    @State private var isPaid = true
    @State private var notes = ""

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

                Section(header: Text("日付・支払い")) {
                    DatePicker("日付", selection: $expenseDate, displayedComponents: .date)

                    Picker("支払い方法", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }

                    Toggle("支払い済み", isOn: $isPaid)
                }

                Section(header: Text("メモ")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(expense == nil ? "新規支出" : "支出編集")
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
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
            .onAppear {
                if let expense = expense {
                    title = expense.wrappedTitle
                    amount = String(expense.amount)
                    category = ExpenseCategory(rawValue: expense.wrappedCategory) ?? .ticket
                    expenseDate = expense.wrappedExpenseDate
                    paymentMethod = PaymentMethod(rawValue: expense.wrappedPaymentMethod) ?? .cash
                    isPaid = expense.isPaid
                    notes = expense.wrappedNotes
                }
            }
        }
    }

    private func save() {
        let entity = expense ?? ExpenseEntity.create(in: viewContext)
        entity.title = title
        entity.amount = Int32(Int(amount) ?? 0)
        entity.category = category.rawValue
        entity.expenseDate = expenseDate
        entity.paymentMethod = paymentMethod.rawValue
        entity.isPaid = isPaid
        entity.notes = notes
        CoreDataStack.shared.saveContext()
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
            .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
    }
}
