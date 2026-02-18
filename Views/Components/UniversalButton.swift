import SwiftUI

struct UniversalButton: View {
    var title: String
    var icon: String
    
    var subtitle: String? = nil
    var statusColor: Color = .gray
    var rightIcon: String = "chevron.right"
    var backgroundColor: Color = .white // Default to white
    
    var alertBadge: String? = nil
    var alertColor: Color = Color(red: 1.0, green: 0.4, blue: 0.4)
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(statusColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.35, green: 0.32, blue: 0.45))
                    
                    if let sub = subtitle {
                        Text(sub)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: rightIcon)
                    .font(.body)
                    .foregroundColor(statusColor)
            }
            .padding()
            .frame(height: 72)
            .background(backgroundColor) // Flexible background
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.35, green: 0.32, blue: 0.45).opacity(0.5), lineWidth: 2) // Added border per prototype
            )
        }
    }
}
