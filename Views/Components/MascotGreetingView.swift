import SwiftUI

struct MascotGreetingView: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Speech Bubble
            Text("Hi! I'm Earnie.\nNice to meet you!")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.35, green: 0.32, blue: 0.45)) // Dark purple text
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    // Thick border from the prototype
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 0.35, green: 0.32, blue: 0.45), lineWidth: 3)
                        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
                )
                .overlay(
                    // Tail pointing down-right towards Earnie
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 22, height: 16)
                        .foregroundColor(.white)
                        // A small hack to create a stroke effect on the tail
                        .overlay(
                            Image(systemName: "arrowtriangle.down")
                                .resizable()
                                .frame(width: 22, height: 16)
                                .foregroundColor(Color(red: 0.35, green: 0.32, blue: 0.45))
                                .font(.system(size: 16, weight: .black))
                        )
                        .offset(x: 25, y: 15), // Positioned at bottom right
                    alignment: .bottomTrailing
                )
                .padding(.bottom, 20) // Lift it so it aligns with his chest
            
            Spacer()
            
            Image("EarnieMascot2") // Your asset
                .resizable()
                .scaledToFit()
                .frame(width: 120)
        }
        .padding(.vertical, 10)
    }
}
