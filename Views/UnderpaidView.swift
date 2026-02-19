import SwiftUI

struct UnderpaidView: View {
    // MARK: - 1. DATA PARAMETERS
    let totalBeforeTax: Double
    let underpaidAmount: Double
    let tax: Double
    let superAmount: Double
    let takeHome: Double

    // MARK: - 2. CUSTOM COLORS
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    let textColor = Color(red: 0.35, green: 0.35, blue: 0.45)
    
    // MARK: - 3. NAVIGATION STATE
    @State private var shouldRedirect = false
    @State private var selectedTab: Tab = .upload
    
    enum Tab {
        case upload
        case archive
    }
    
    // MARK: - 4. MAIN BODY
    var body: some View {
        ZStack {
            // MARK: Routing Logic
            if shouldRedirect {
                // Hand the data off to the chart view
                AnalysisUnderpaidInsightView(
                    totalBeforeTax: totalBeforeTax,
                    underpaidAmount: underpaidAmount,
                    tax: tax,
                    superAmount: superAmount,
                    takeHome: takeHome
                )
                .transition(.opacity) // Smooth fade transition
            } else {
                underpaidSplashContent
                    .transition(.opacity)
            }
        }
        // MARK: Auto-Redirect Timer
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    shouldRedirect = true
                }
            }
        }
    }
    
    // MARK: - 5. SPLASH SCREEN CONTENT
    var underpaidSplashContent: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 1.0)
                .ignoresSafeArea()

            
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
                
                // MARK: Center Warning Text
                VStack(spacing: 10) {
                    Text("You are").font(.system(size: 34, weight: .medium)).foregroundColor(.pink)
                    Text("Underpaid!!").font(.system(size: 40, weight: .bold)).foregroundColor(.pink)
                    Text("$\(Int(underpaidAmount))").font(.system(size: 42, weight: .bold)).foregroundColor(.pink)
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
        HStack(spacing: 0) {
            tabButton(title: "Upload", icon: "square.and.arrow.up", tab: .upload)
            tabButton(title: "Archive", icon: "doc.text", tab: .archive)
        }
        .padding(8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 10)
    }
    
    func tabButton(title: String, icon: String, tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = tab }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 18, weight: .semibold))
                Text(title).font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(selectedTab == tab ? .blue : .gray.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.blue.opacity(0.12))
                            .background(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            )
            .padding(.horizontal, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    UnderpaidView(
        totalBeforeTax: 565,
        underpaidAmount: 106,
        tax: 56,
        superAmount: 61,
        takeHome: 435
    )
}
