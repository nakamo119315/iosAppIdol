import SwiftUI
import CoreData

struct BudgetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExpenseEntity.expenseDate, ascending: false)],
        animation: .default
    ) private var expenses: FetchedResults<ExpenseEntity>

    @State private var showingAddSheet = false

    private var totalAmount: Int {
        expenses.reduce(0) { $0 + Int($1.amount) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary
                VStack(spacing: 8) {
                    Text("今月の支出")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("¥\(totalAmount.withComma)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)

                    Text("\(expenses.count)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(.secondarySystemBackground))

                // List
                if expenses.isEmpty {
                    emptyState
                } else {
                    expenseList
                }
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

    private var expenseList: some View {
        List {
            ForEach(expenses, id: \.self) { expense in
                NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                    ExpenseRowView(expense: expense)
                }
            }
            .onDelete(perform: deleteExpenses)
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "yensign.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("支出がありません")
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
        .frame(maxHeight: .infinity)
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(expenses[index])
        }
        CoreDataStack.shared.saveContext()
    }
}

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
        .padding(.vertical, 4)
    }
}

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
