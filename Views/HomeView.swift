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
    @State private var navigateToRoster = false
    @State private var isProcessing = false
    @State private var isError = false
    @State private var errorMessage = ""
    
    // 🔴 NEW: Temporary states for the demo so the checkmarks reset every time you open the app
    @State private var hasUploadedRoster = false
    @State private var hasUploadedPayslip = false

    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98)

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // Using the updated name for the presentation
                        HomeHeaderView(name: "Cameron")
                        
                        // --- 3. Action Cards Row ---
                        HStack(spacing: 15) {
                            
                            // STEP 1: Roster Card
                            SquareActionCard(
                                title: "Upload Roster",
                                subtitle: "Step 1",
                                icon: "calendar",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                isCompleted: hasUploadedRoster, // 🔴 Tied to our safe temporary state
                                action: { showRosterScanner = true }
                            )
                            .onLongPressGesture {
                                triggerFakeError()
                            }
                            
                            // STEP 2: Payslip Card
                            SquareActionCard(
                                title: "Upload Payslip",
                                subtitle: "Step 2",
                                icon: "contextualmenu.and.pointer.arrow",
                                color: Color(red: 0.58, green: 0.69, blue: 0.95),
                                isCompleted: hasUploadedPayslip, // 🔴 Tied to our safe temporary state
                                action: { showScanner = true }
                            )
                            .onLongPressGesture {
                                triggerFakeLoading()
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
            
            // --- 4. Navigation Destinations ---
            .navigationDestination(isPresented: $navigateToAnalysis) {
                if isDemoMode {
                    AnalysisResultView(analysis: PayslipAnalysis(
                        totalBeforeTax: 978.72,
                        tax: 248.00,
                        superAmount: 100.18,
                        takeHome: 730.72,
                        expectedTakeHome: 895.50
                    ))
                } else {
                    AnalysisResultView(analysis: PayslipAnalysis(
                        totalBeforeTax: 0.0, tax: 0.0, superAmount: 0.0, takeHome: 0.0, expectedTakeHome: 0.0
                    ))
                }
            }
            .navigationDestination(isPresented: $navigateToRoster) {
                RosterView()
            }
            
            // --- 5. Pop-up Sheets ---
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedData: $scannedData)
            }
            .sheet(isPresented: $showRosterScanner) {
                RosterScannerView(onSave: {
                    // 🔴 FIX: Flip the Roster checkmark to true when the user saves!
                    withAnimation {
                        hasUploadedRoster = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigateToRoster = true
                    }
                })
            }
            
            // --- 6. Intercepting the OCR Data ---
            .onChange(of: scannedData) {
                if scannedData != nil {
                    showScanner = false
                    
                    // 🔴 FIX: Flip the Payslip checkmark to true when the scan finishes!
                    withAnimation {
                        hasUploadedPayslip = true
                    }
                    
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
        
        withAnimation {
            hasUploadedPayslip = true
        }
        
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
