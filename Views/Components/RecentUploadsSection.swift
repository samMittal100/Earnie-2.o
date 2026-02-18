import SwiftUI

struct RecentUploadsSection: View {
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Uploads")
                .font(.headline)
                .foregroundColor(darkPurple)
            
            VStack(spacing: 12) {
                // MARK: - Pending Row (White background, Dark Text, Dark Border)
                UniversalButton(
                    title: "October Pay Slip - Pending",
                    subtitle: "Pending Review",
                    titleColor: darkPurple,
                    subtitleColor: .gray,
                    statusColor: darkPurple,
                    rightIcon: "clock.fill",
                    backgroundColor: .white,
                    borderColor: darkPurple
                ) { }
                
                // MARK: - Approved Row (Blue background, White Text, No Border)
                UniversalButton(
                    title: "September Invoice - Approved",
                    subtitle: "Review",
                    titleColor: .white,
                    subtitleColor: .white.opacity(0.8),
                    statusColor: .white,
                    rightIcon: "checkmark.circle.fill",
                    backgroundColor: primaryBlue,
                    borderColor: .clear // No border
                ) { }
                
                // MARK: - Second Approved Row
                UniversalButton(
                    title: "September Invoice - Approved",
                    subtitle: "Review",
                    titleColor: .white,
                    subtitleColor: .white.opacity(0.8),
                    statusColor: .white,
                    rightIcon: "checkmark.circle.fill",
                    backgroundColor: primaryBlue,
                    borderColor: .clear // No border
                ) { }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea()
        RecentUploadsSection()
            .padding()
    }
}
