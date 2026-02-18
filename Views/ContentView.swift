import SwiftUI

struct ContentView: View {
    // MARK: - State
    @State private var selectedTab = 0
    
    // MARK: - Initialization
    init() {
        // Hides the default Apple Tab Bar so our custom one works
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        // MARK: - Main Layout Stack
        ZStack(alignment: .bottom) {
            
            // MARK: Background
            Color(red: 0.96, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            // MARK: Tab Navigation Routing
            TabView(selection: $selectedTab) {
                
                HomeView()
                    .tag(0)
                
                ArchiveView()
                    .tag(1)
            }
            
            // MARK: Global Custom Tab Bar
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
