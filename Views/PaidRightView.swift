import SwiftUI

struct PaidRightView: View {
    
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    let textColor = Color(red: 0.35, green: 0.35, blue: 0.45)
    
    @State private var selectedTab: Tab = .upload
    // MARK: - Navigation State
    @State private var shouldRedirect = false
    
    enum Tab {
        case upload
        case archive
    }
    
    var body: some View {
        ZStack {
            if shouldRedirect {
                // MARK: - Redirect Target
                // Transition to the AnalysisPaidView after the timer ends
                AnalysisPaidView()
                    .transition(.opacity) // Smooth fade transition
            } else {
                // MARK: - Current Splash Content
                splashContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            // MARK: - Timer Logic
            // Start a 5-second timer when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    shouldRedirect = true
                }
            }
        }
    }
    
    // Extracted the splash content to keep the body clean
    var splashContent: some View {
        ZStack {
            primaryBlue.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // MARK: - Left Character (Top Left)
                HStack {
                    Image("characterLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .offset(x: -30, y: 20)
                    
                    Spacer()
                }
                
                Spacer()
                
                // MARK: - Center Text
                VStack(spacing: 10) {
                    Text(" YOU HAVE BEEN")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(.pink)
                    
                    Text("PAID RIGHT!!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.pink)
                        .offset(x: 10, y: -7)
                    
                    Text("🎉")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.pink)
                        .offset(x: 10, y: -7)
                }
                
                Spacer()
                
                // MARK: - Right Character (Bottom Right)
                HStack {
                    Spacer()
                    
                    Image("characterRight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .offset(x: 10, y: 20)
                }
                
                Spacer()
                
                // MARK: - Bottom Glass Tab Bar
                glassTabBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Helper Views
    
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
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.8), Color.white.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
    }
}

#Preview {
    PaidRightView()
}
