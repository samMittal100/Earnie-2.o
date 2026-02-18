import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabBarButton(
                icon: "arrow.up.doc.fill",
                title: "Upload",
                tab: 0,
                selectedTab: $selectedTab
            )
            
            Spacer()
            TabBarButton(
                icon: "doc.text.fill",
                title: "Archive",
                tab: 1,
                selectedTab: $selectedTab
            )
        }
        .padding(12)
        .background(
            Capsule()
                .fill(Color(white: 0.2))
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 10)
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
                            .stroke(Color.purple, lineWidth: 2)
                            .background(Capsule().fill(Color.purple.opacity(0.15)))
                    }
                }
            )
            .foregroundColor(selectedTab == tab ? .white : .gray)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
        .preferredColorScheme(.dark)
}
