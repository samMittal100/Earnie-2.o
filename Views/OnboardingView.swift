import SwiftUI

struct OnboardingView: View {
    // MARK: - 1. CUSTOM COLORS
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    let textColor = Color(red: 0.35, green: 0.35, blue: 0.45)
    
    // MARK: - 2. STATE
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    // MARK: - 3. MAIN BODY
    var body: some View {
        VStack {
            Spacer(minLength: 40)
            
            // MARK: Text & Branding
            Text("Welcome to Earnie!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(primaryBlue)
            
            Text("Your Personal Payslip Assistance")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
                .padding(.top, 8)
            
            Text("First, let's enter a few details to get you started.")
                .font(.system(size: 16))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 4)
            
            Spacer()
            
            // 🔴 THE FIX: Replaced the static Image with the Looping Video Player
            // Note: Ensure the string perfectly matches the file name you gave it in Step 1!
            LoopingVideoPlayer(videoName: "HappyEarnie", videoExtension: "mp4")
                .frame(width: 400, height: 550) // Adjust size as needed
            
            Spacer()
            
            // MARK: Call To Action Button
            Button {
                withAnimation(.spring) {
                    hasSeenOnboarding = true
                }
            } label: {
                Text("Get Started!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(primaryBlue).opacity(0.70))
                    .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    OnboardingView()
}
