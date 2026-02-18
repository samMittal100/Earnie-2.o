import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabBarButton(
                icon: "square.and.arrow.up",
                title: "Upload",
                tab: 0,
                selectedTab: $selectedTab
            )
            
            Spacer()
            
            TabBarButton(
                icon: "doc.text",
                title: "Archive",
                tab: 1,
                selectedTab: $selectedTab
            )
        }
        .padding(12)
        .background(
            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .background(.ultraThinMaterial) // Added Glass effect
                Capsule()
                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            }
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
}

struct TabBarButton: View {
    var icon: String
    var title: String
    var tab: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if selectedTab == tab {
                        Capsule()
                            .fill(Color.gray.opacity(0.1)) // Subtle highlight
                    }
                }
            )
            .foregroundColor(selectedTab == tab ? .blue : .gray) // Blue active state
        }
    }
}
