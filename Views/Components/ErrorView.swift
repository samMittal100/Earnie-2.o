import SwiftUI

struct ErrorView: View {
    // MARK: - 1. DATA PARAMETERS
    var message: String
    var dismissAction: () -> Void
    
    // MARK: - 2. CUSTOM COLORS
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    let errorRed = Color(red: 0.95, green: 0.3, blue: 0.3)
    
    // MARK: - 3. MAIN BODY
    var body: some View {
        ZStack {
            
            // MARK: Dimmed Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { dismissAction() }
            
            // MARK: Error Card
            VStack(spacing: 25) {
                
                // MARK: Speech Bubble
                Text(message)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(darkPurple)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .background(
                        SpeechBubbleShape()
                            .fill(Color.white)
                            .overlay(SpeechBubbleShape().stroke(errorRed, lineWidth: 3))
                    )
                    .padding(.bottom, 20)
                
                // MARK: Sad Mascot
                Image("characterRight")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .grayscale(0.5) // Makes him look disabled/sad
                
                // MARK: Try Again Button
                Button(action: dismissAction) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(errorRed)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .shadow(radius: 20)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ErrorView(message: "Oops! I couldn't read that.\nMake sure the image is clear.") {
        print("Dismissed")
    }
}
