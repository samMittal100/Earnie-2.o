import SwiftUI

struct SquareActionCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var color: Color
    var isCompleted: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    // Top Left Icon (e.g. checkmark.seal)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Top Right Icon (Square Plus or Checkmark)
                    Image(systemName: isCompleted ? "checkmark.square.fill" : "plus.app")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(subtitle.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8)) // White text
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // White text
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 150) // More square-shaped
            .background(
                // Soft gradient blue background from prototype
                LinearGradient(
                    colors: [color.opacity(0.85), color],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(24)
            .shadow(color: color.opacity(0.4), radius: 15, x: 0, y: 10) // Blue shadow
        }
    }
}

#Preview {
    SquareActionCard(
        title: "Upload Roster",
        subtitle: "Step 2",
        icon: "calendar",
        color: Color(red: 0.58, green: 0.69, blue: 0.95),
        isCompleted: true,
        action: {print("button was pressed")}
        )
        }
