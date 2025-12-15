import SwiftUI
import CoreData

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

            PracticeListView()
                .tabItem {
                    Label("会話練習", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(2)

            ReportListView()
                .tabItem {
                    Label("レポ", systemImage: "text.bubble")
                }
                .tag(3)
        }
        .accentColor(.pink)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
    }
}
