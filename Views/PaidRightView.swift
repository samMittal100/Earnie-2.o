import SwiftUI

struct PaidRightView: View {
    // MARK: - 1. DATA PARAMETERS
    let totalEarnings: Double
    let tax: Double
    let superAmount: Double
    let takeHome: Double

    // MARK: - 2. CUSTOM COLORS
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    let textColor = Color(red: 0.35, green: 0.35, blue: 0.45)
    
    // MARK: - 3. NAVIGATION STATE
    @State private var selectedTab: Tab = .upload
    @State private var shouldRedirect = false
    
    enum Tab {
        case upload
        case archive
    }
    
    // MARK: - 4. MAIN BODY
    var body: some View {
        ZStack {
            // MARK: Routing Logic
            if shouldRedirect {
                AnalysisPaidView(
                    totalEarnings: totalEarnings,
                    tax: tax,
                    superAmount: superAmount,
                    takeHome: takeHome
                )
                .transition(.opacity)
            } else {
                splashContent.transition(.opacity)
            }
        }
        // MARK: Auto-Redirect Timer
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    shouldRedirect = true
                }
            }
        }
    }
    
    // MARK: - 5. SPLASH SCREEN CONTENT
    var splashContent: some View {
        ZStack {
            primaryBlue.opacity(0.2).ignoresSafeArea()
            VStack {
                Spacer()
                
                // MARK: Left Mascot
                HStack {
                    Image("characterLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .offset(x: -30, y: 20)
                    Spacer()
                }
                
                Spacer()
                
                // MARK: Center Text
                VStack(spacing: 10) {
                    Text(" YOU HAVE BEEN").font(.system(size: 34, weight: .medium)).foregroundColor(.pink)
                    Text("PAID RIGHT!!").font(.system(size: 40, weight: .bold)).foregroundColor(.pink).offset(x: 10, y: -7)
                    Text("🎉").font(.system(size: 42, weight: .bold)).foregroundColor(.pink).offset(x: 10, y: -7)
                }
                
                Spacer()
                
                // MARK: Right Mascot
                HStack {
                    Spacer()
                    Image("characterRight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .offset(x: 10, y: 20)
                }
                
                Spacer()
                
                // 🔴 THE FIX: Commented out to prevent double-stacking tab bars!
                // glassTabBar.padding(.horizontal, 24).padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - 6. UNUSED TAB BAR COMPONENTS (HIDDEN)
    var glassTabBar: some View {
        HStack(spacing: 20) {
            footerButton(label: "Upload", icon: "square.and.arrow.up", color: .black)
            footerButton(label: "Archive", icon: "doc.text", color: .blue)
        }
        .padding(.horizontal, 20)
    }
    
    func footerButton(label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
            Text(label).font(.caption).bold()
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(liquidGlassBackground)
        .cornerRadius(20)
    }

    var liquidGlassBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
    }
}

#Preview {
    PaidRightView(
        totalEarnings: 565,
        tax: 56,
        superAmount: 61,
        takeHome: 435
    )
}
