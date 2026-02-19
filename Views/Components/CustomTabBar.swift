import SwiftUI

struct CustomTabBar: View {
    // MARK: - 1. NAVIGATION BINDING
    @Binding var selectedTab: Int
    
    // MARK: - 2. MAIN BODY
    var body: some View {
        HStack {
            // MARK: Upload Tab
            TabBarButton(
                icon: "square.and.arrow.up",
                title: "Upload",
                tab: 0,
                selectedTab: $selectedTab
            )
            
            Spacer()
            
            // MARK: Archive Tab
            TabBarButton(
                icon: "doc.text",
                title: "Archive",
                tab: 1,
                selectedTab: $selectedTab
            )
        }
        // 🔴 FIX 1: Shaved down the outer vertical padding from 12 to 6
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        // MARK: Glassmorphism Background
        .background(
            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                
                Capsule()
                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            }
        )
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
}

// MARK: - 3. TAB BUTTON COMPONENT
struct TabBarButton: View {
    var icon: String
    var title: String
    var tab: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            // 🔴 FIX 2: Tighter spacing between the icon and text (4 down to 2)
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            // 🔴 FIX 3: Shaved down the inner button padding from 12 to 8
            .padding(.vertical, 8)
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

#Preview {
    ZStack {
        Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea()
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(0))
        }
    }
}
