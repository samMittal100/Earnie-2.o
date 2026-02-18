import SwiftUI
import SwiftData

struct HomeView: View {
    // --- 1. Database Queries ---
    @Query private var allRosters: [Roster]
    @Query private var allPayslips: [Payslip]
    
    @State private var showScanner = false
    @State private var showRosterScanner = false
    @State private var scannedData: PayslipData? = nil
    
    // --- 2. Navigation, State & DEMO Controls ---
    @State private var isDemoMode = true    // 🔴 THE MASTER DEMO SWITCH
    @State private var navigateToAnalysis = false
    @State private var isProcessing = false // Triggers LoadingView
    @State private var isError = false      // Triggers ErrorView
    @State private var errorMessage = ""

    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98)

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        HomeHeaderView(name: "Human")
                        
                        // --- 3. Action Cards Row ---
                        HStack(spacing: 15) {
                            // Payslip Card
                            SquareActionCard(
                                title: "Upload Payslip",
                                subtitle: "Step 1",
                                icon: "contextualmenu.and.pointer.arrow",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                isCompleted: !allPayslips.isEmpty,
                                action: { showScanner = true }
                            )
                            // --- DEVELOPER HACK: TEST LOADING STATE ---
                            .onLongPressGesture {
                                triggerFakeLoading()
                            }
                            
                            // Roster Card
                            SquareActionCard(
                                title: "Upload Roster",
                                subtitle: "Step 2",
                                icon: "calendar",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                isCompleted: !allRosters.isEmpty,
                                action: { showRosterScanner = true }
                            )
                            // --- DEVELOPER HACK: TEST ERROR STATE ---
                            .onLongPressGesture {
                                triggerFakeError()
                            }
                        }
                        
                        MascotGreetingView()
                        RecentUploadsSection()
                        Spacer(minLength: 100)
                    }
                    .padding(24)
                }
                
                // --- THE LOADING OVERLAY ---
                if isProcessing {
                    LoadingView()
                        .transition(.opacity.animation(.easeInOut))
                        .allowsHitTesting(true)
                        .zIndex(1)
                }
                
                // --- THE ERROR OVERLAY ---
                if isError {
                    ErrorView(message: errorMessage) {
                        withAnimation(.easeInOut) {
                            isError = false
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(2)
                }
            }
            .navigationBarBackButtonHidden(true)
            
            // --- 4. Navigation Destination (THE MAGIC HAPPENS HERE) ---
            .navigationDestination(isPresented: $navigateToAnalysis) {
                if isDemoMode {
                    // THE SMOKE & MIRRORS DEMO DATA
                    AnalysisResultView(analysis: PayslipAnalysis(
                        totalBeforeTax: 978.72,  // Exact from your paper
                        tax: 248.00,             // Exact from your paper
                        superAmount: 100.18,     // Exact from your paper
                        takeHome: 730.72,        // Exact from your paper
                        expectedTakeHome: 895.50 // FAKED: Triggers the $164 Underpayment
                    ))
                } else {
                    // JEFF'S REAL BACKEND DATA (He connects his variables here later)
                    AnalysisResultView(analysis: PayslipAnalysis(
                        totalBeforeTax: 0.0,
                        tax: 0.0,
                        superAmount: 0.0,
                        takeHome: 0.0,
                        expectedTakeHome: 0.0
                    ))
                }
            }
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedData: $scannedData)
            }
            .sheet(isPresented: $showRosterScanner) {
                RosterScannerView()
            }
            
            // --- 5. Intercepting the OCR Data ---
            .onChange(of: scannedData) {
                if scannedData != nil {
                    showScanner = false
                    isProcessing = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        isProcessing = false
                        navigateToAnalysis = true
                    }
                }
            }
        }
    }
    
    // MARK: - Debug Testing Functions
    func triggerFakeLoading() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isProcessing = false
            navigateToAnalysis = true
        }
    }
    
    func triggerFakeError() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        errorMessage = "Oops! I couldn't find a payslip in that image.\n\nPlease try again with better lighting."
        withAnimation(.spring) {
            isError = true
        }
    }
}

#Preview {
    HomeView()
}
