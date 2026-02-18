import SwiftUI

struct LoadingView: View {
    // MARK: - 1. CUSTOM COLORS
    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98)
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    
    // MARK: - 2. ANIMATION STATES
    @State private var isBouncing = false
    @State private var showDot1 = false
    @State private var showDot2 = false
    @State private var showDot3 = false
    
    // MARK: - 3. MAIN BODY
    var body: some View {
        ZStack {
            // Solid background to cover the screen beneath
            bgColor.ignoresSafeArea()
            
            // Semi-transparent overlay to dim the screen
            Color.black.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: -10) {
                    
                    // The Bouncing Mascot
                    Image("EarnieMascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .offset(y: isBouncing ? -10 : 5)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                            value: isBouncing
                        )
                    
                    // The Thinking Dots
                    HStack(spacing: 4) {
                        ThinkingDot(isOn: showDot1)
                        ThinkingDot(isOn: showDot2)
                        ThinkingDot(isOn: showDot3)
                    }
                    .offset(y: -20) // Position near his head
                }
                
                Text("Earnie is thinking...")
                    .font(.headline)
                    .foregroundColor(darkPurple)
            }
        }
        .onAppear {
           startAnimations()
        }
    }
    
    // MARK: - 4. ANIMATION LOGIC
    func startAnimations() {
        // Start the main body bounce immediately
        isBouncing = true
        
        // Stagger the dots so they appear one by one
        withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
            showDot1 = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                showDot2 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                showDot3 = true
            }
        }
    }
}

// MARK: - 5. HELPER COMPONENT
struct ThinkingDot: View {
    var isOn: Bool
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    
    var body: some View {
        Circle()
            .fill(darkPurple)
            .frame(width: 8, height: 8)
            .opacity(isOn ? 1 : 0.3)
            .scaleEffect(isOn ? 1 : 0.8)
    }
}

#Preview {
    LoadingView()
}
