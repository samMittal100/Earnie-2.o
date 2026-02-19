import SwiftUI
import SwiftData // Assuming Jeff put SwiftData here

@main
struct EarnieApp: App {
    // 🔴 THE FIX: The app checks this memory flag immediately upon launching
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                // If they've seen it, load the main app
                ContentView()
                    // .modelContainer(for: [Roster.self, Payslip.self]) // Keep whatever container you had here!
            } else {
                // If it's their first time, show onboarding
                OnboardingView()
            }
        }
    }
}
