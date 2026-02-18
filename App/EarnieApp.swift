import SwiftUI
import SwiftData

@main
struct EarnieApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView()
        }
        // 👇 This is the fix. We changed 'Item.self' to 'Payslip.self'
        .modelContainer(for: Payslip.self)
    }
}
