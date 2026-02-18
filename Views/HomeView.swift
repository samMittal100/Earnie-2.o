import SwiftUI
import SwiftData

struct HomeView: View {
    // --- 1. Database Queries ---
    // These automatically update the UI when data is added/deleted
    @Query private var allRosters: [Roster]
    @Query private var allPayslips: [Payslip]
    
    @State private var showScanner = false
    @State private var showRosterScanner = false
    @State private var scannedData: PayslipData? = nil
    
    // --- 2. Navigation State ---
    // When this becomes true, the app jumps to the Analysis screen
    @State private var navigateToAnalysis = false

    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98)

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        HomeHeaderView(name: "Earnie")
                        
                        // --- 3. Action Cards Row ---
                        HStack(spacing: 15) {
                            // Payslip Card
                            SquareActionCard(
                                title: "Upload Payslip",
                                subtitle: "Step 1",
                                icon: "checkmark.seal.fill",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                isCompleted: !allPayslips.isEmpty, // Checkmark logic
                                action: { showScanner = true }
                            )
                            
                            // Roster Card
                            SquareActionCard(
                                title: "Upload Roster",
                                subtitle: "Step 2",
                                icon: "calendar.badge.plus",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                isCompleted: !allRosters.isEmpty, // Checkmark logic
                                action: { showRosterScanner = true }
                            )
                        }
                        
                        MascotGreetingView()
                        RecentUploadsSection()
                        Spacer(minLength: 100)
                    }
                    .padding(24)
                }
            }
            // --- 4. Navigation Destination ---
            // This is the hidden "Bam!" that takes you to analysis
            .navigationDestination(isPresented: $navigateToAnalysis) {
                // Here we pass dummy data for now; Jeff will replace this with calculation logic later
                AnalysisResultView(analysis: PayslipAnalysis(
                    totalBeforeTax: 565,
                    tax: 56,
                    superAmount: 61,
                    takeHome: 435,
                    expectedTakeHome: 541
                ))
            }
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedData: $scannedData)
            }
            .sheet(isPresented: $showRosterScanner) {
                RosterScannerView()
            }
            .onChange(of: scannedData) {
                // As soon as OCR finished, trigger the navigation
                if scannedData != nil {
                    navigateToAnalysis = true
                }
            }
        }
    }
}
