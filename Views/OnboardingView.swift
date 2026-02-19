import SwiftUI

struct OnboardingView: View {
    // MARK: - 1. CUSTOM COLORS
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    let textColor = Color(red: 0.35, green: 0.35, blue: 0.45)
    
    // 🔴 THE FIX: This permanently saves the state to the device memory
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    // MARK: - 2. MAIN BODY
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
            
            // MARK: Mascot Image
            Image("EarnieMascot")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
            
            Spacer()
            
            // MARK: Call To Action Button
            Button {
                // 🔴 THE FIX: Flipping this to true instantly swaps the root view
                withAnimation(.spring) {
                    hasSeenOnboarding = true
                }
            } label: {
                Text("Get Started!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.blue.opacity(0.70))
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
