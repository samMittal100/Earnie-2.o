import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Forces the light background to the absolute bottom of the screen
            Color(red: 0.96, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                
                HomeView()
                    .tag(0)
                
                // Assuming you have an ArchiveView file created
                ArchiveView()
                    .tag(1)
            }
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        // DELETED: .preferredColorScheme(.dark)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
