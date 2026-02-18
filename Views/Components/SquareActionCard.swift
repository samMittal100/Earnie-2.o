import SwiftUI

struct SquareActionCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(color)
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill") // Matching prototype icon
                        .font(.title3)
                        .foregroundColor(color.opacity(0.3))
                }
                
                Spacer()
                
                Text(subtitle.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.35, green: 0.32, blue: 0.45)) // Dark text
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color.white) // Changed from dark to white
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10) // Soft shadow
        }
    }
}
