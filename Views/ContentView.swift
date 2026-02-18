import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            TabView(selection: $selectedTab) {
                
                HomeView()
                    .tag(0)
                
                ArchiveView()
                    .tag(1)
            }
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
