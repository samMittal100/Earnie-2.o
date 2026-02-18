import SwiftUI

struct GlassButton: View {
    // MARK: - 1. DATA PARAMETERS
    var title: String
    var icon: String
    var color: Color = Color(white: 0.15)
    var action: () -> Void

    // MARK: - 2. MAIN BODY
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title2)
            }
            .padding()
            .frame(height: 72)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            GlassButton(title: "Upload Pay Slip", icon: "plus.app.fill") {}
            GlassButton(title: "Upload Roster", icon: "doc.text") {}
        }
        .padding()
    }
}
