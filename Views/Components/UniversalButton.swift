import SwiftUI

struct UniversalButton: View {
    var title: String
    var icon: String
    
    var subtitle: String? = nil
    var statusColor: Color = .white
    var rightIcon: String = "chevron.right"
    var backgroundColor: Color = Color(white: 0.15)
    
    var alertBadge: String? = nil
    var alertColor: Color = Color(red: 1.0, green: 0.4, blue: 0.4)
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                
                Image(systemName: icon)
                    .font(subtitle == nil ? .title2 : .title3)
                    .foregroundColor(subtitle == nil ? .white : .gray)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if let sub = subtitle {
                        Text(sub)
                            .font(.caption)
                            .foregroundColor(statusColor)
                    }
                }
                
                Spacer()
                
                if let badge = alertBadge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(alertColor)
                        .cornerRadius(12)
                } else {
                    Image(systemName: rightIcon)
                        .font(.body)
                        .foregroundColor(subtitle == nil ? .white.opacity(0.5) : statusColor)
                }
            }
            .padding()
            .frame(height: 72)
            .background(backgroundColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            UniversalButton(title: "Upload", icon: "plus", backgroundColor: .blue) {}
            
            UniversalButton(
                title: "March Payslip",
                icon: "doc.text.fill",
                subtitle: "Processed",
                statusColor: .gray,
                alertBadge: "Underpaid $45"
            ) {}
        }
        .padding()
    }
}
