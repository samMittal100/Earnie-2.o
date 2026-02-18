import SwiftUI

struct HomeView: View {
    @State private var showScanner = false
    @State private var showRosterScanner = false
    @State private var scannedData: PayslipData? = nil
    
    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98) // Light Prototype Background

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // 1. Header Component
                        HomeHeaderView(name: "Earnie")
                        
                        // 2. Action Cards Row
                        HStack(spacing: 15) {
                            SquareActionCard(
                                title: "Upload Payslip",
                                subtitle: "Step 1",
                                icon: "checkmark.seal.fill",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                action: { showScanner = true }
                            )
                            
                            SquareActionCard(
                                title: "Upload Roster",
                                subtitle: "Step 2",
                                icon: "calendar.badge.plus",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                action: { showRosterScanner = true }
                            )
                        }
                        
                        // 3. Mascot & Speech Bubble Component
                        MascotGreetingView()
                        
                        // 4. Recent Uploads Section
                        RecentUploadsSection()
                        
                        Spacer(minLength: 100)
                    }
                    .padding(24)
                }
            }
            .sheet(isPresented: $showScanner) { ScannerView(scannedData: $scannedData) }
            .sheet(isPresented: $showRosterScanner) { RosterScannerView() }
            .overlay {
                if let data = scannedData {
                    AnalysisResultOverlay(data: data) { scannedData = nil }
                }
            }
        }
    }
}
