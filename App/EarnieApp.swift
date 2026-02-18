import SwiftUI
import SwiftData

@main
struct EarnieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 👇 This is the fix. We changed 'Item.self' to 'Payslip.self'
        .modelContainer(for: Payslip.self)
    }
}
