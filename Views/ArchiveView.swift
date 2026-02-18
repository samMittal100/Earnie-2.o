import SwiftUI

struct ArchiveView: View {
    @State private var selectedDate = Date()
    @State private var selectedFilter = "All"
    let filters = ["All", "Payslips", "Rosters"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Archives")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .colorScheme(.dark)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.15))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 12) {
                        
                        UniversalButton(
                            title: "March 2025 Payslip",
                            icon: "doc.text.fill",
                            subtitle: "Total: $354",
                            statusColor: .gray,
                            alertBadge: "Underpaid: $45"
                        ) {
                            print("Open Analysis for March")
                        }
                        
                        UniversalButton(
                            title: "February 2025 Payslip",
                            icon: "checkmark.shield.fill",
                            subtitle: "Total: $484",
                            statusColor: .green,
                            rightIcon: "checkmark.circle.fill"
                        ) {
                            print("Open Feb")
                        }
                        
                        UniversalButton(
                            title: "January 2025 Payslip",
                            icon: "calendar",
                            subtitle: "Total: $234",
                            statusColor: .green,
                            rightIcon: "checkmark.circle.fill"
                        ) {
                            print("Open Roster")
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(24)
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    ArchiveView()
}
