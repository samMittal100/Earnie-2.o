import SwiftUI

struct HomeView: View {
    // --- State Variables ---
    @State private var showScanner = false
    
    // Holds the structured data from OCR
    @State private var scannedData: PayslipData? = nil
    @State private var showRosterScanner = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // --- 1. Header ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hi, Earnie 👋")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Let's get your work sorted.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // --- 2. Action Buttons ---
                    HStack(spacing: 16) {
                        SquareActionCard(
                            title: "Upload Payslip",
                            subtitle: "Step 1",
                            icon: "doc.text.fill",
                            color: Color(red: 0.28, green: 0.58, blue: 0.86)
                        ) {
                            showScanner = true
                        }
                        
                        SquareActionCard(
                            title: "Upload Roster",
                            subtitle: "Step 2",
                            icon: "calendar.badge.plus",
                            color: Color(red: 0.35, green: 0.80, blue: 0.55)
                        ) {
                            showRosterScanner = true
                        }
                    }
                    
                    // --- 3. Recent Uploads ---
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Uploads")
                                .font(.title3).fontWeight(.bold).foregroundColor(.white)
                            Spacer()
                            Button("See All") {}.font(.subheadline).foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 12) {
                            UniversalButton(
                                title: "October Pay Slip",
                                icon: "doc.text.fill",
                                subtitle: "Pending Review",
                                statusColor: .orange,
                                rightIcon: "hourglass"
                            ) { print("Tapped") }
                        }
                    }
                    Spacer()
                }
                .padding(24)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .scrollIndicators(.hidden)
            
            // --- THE SCANNER SHEET ---
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedData: $scannedData)
            }
            .sheet(isPresented: $showRosterScanner) {
                RosterScannerView()
            }
            
            // --- THE RESULT OVERLAY ---
            .overlay {
                if let data = scannedData {
                    ZStack {
                        Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                            .onTapGesture { scannedData = nil }
                        
                        VStack(spacing: 20) {
                            Text("Payslip Analyzed")
                                .font(.title2).fontWeight(.bold).foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ResultRow(label: "Gross Pay", amount: data.grossPay, icon: "dollarsign.circle.fill", color: .blue)
                                ResultRow(label: "Tax Withheld", amount: data.tax, icon: "building.columns.fill", color: .orange)
                                ResultRow(label: "Superannuation", amount: data.superannuation, icon: "chart.bar.fill", color: .purple)
                                Divider().background(Color.gray)
                                ResultRow(label: "Net Pay", amount: data.netPay, icon: "arrow.down.circle.fill", color: .green)
                            }
                            .padding()
                            .background(Color(white: 0.15))
                            .cornerRadius(16)
                            
                            Button("Done") { scannedData = nil }
                                .buttonStyle(.borderedProminent)
                        }
                        .padding(24)
                    }
                }
            }
        }
    }
}

// Helper UI Component for the Overlay
struct ResultRow: View {
    let label: String
    let amount: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2).foregroundColor(color).frame(width: 40)
            VStack(alignment: .leading) {
                Text(label).font(.caption).foregroundColor(.gray)
                Text("$\(amount)").font(.title3).fontWeight(.bold).foregroundColor(.white)
            }
            Spacer()
        }
        .padding(8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
}
