import SwiftUI

struct UniversalButton: View {
    var title: String
    var subtitle: String
    var titleColor: Color
    var subtitleColor: Color
    var statusColor: Color
    var rightIcon: String
    var backgroundColor: Color
    var borderColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(titleColor) // Dynamic text color
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(subtitleColor) // Dynamic text color
                }
                
                Spacer()
                
                // Right-side icon only
                Image(systemName: rightIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 20)
            .frame(height: 72)
            .background(backgroundColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: 2) // Dynamic border
            )
        }
    }
}
