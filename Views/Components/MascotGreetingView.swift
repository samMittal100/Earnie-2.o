import SwiftUI // Essential fix

struct MascotGreetingView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            // Speech Bubble
            Text("Hi! I'm Earnie.\nNice to meet you!")
                .font(.system(size: 14, weight: .medium))
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10)
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .resizable()
                        .frame(width: 15, height: 12)
                        .foregroundColor(.white)
                        .offset(x: -8, y: 12),
                    alignment: .leading
                )
            
            Spacer()
            
            // Using your updated asset
            Image("earnieMascot2")
                .resizable()
                .scaledToFit()
                .frame(width: 130)
        }
        .padding(.vertical, 10)
    }
}
