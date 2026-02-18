import SwiftUI

// MARK: - Payslip Model
struct PayslipAnalysis {
    let totalBeforeTax: Double
    let tax: Double
    let superAmount: Double
    let takeHome: Double
    let expectedTakeHome: Double
    
    // Calculate underpayment
    var underpaidAmount: Double {
        max(0, expectedTakeHome - takeHome)
    }
    
    // Check if underpaid
    var isUnderpaid: Bool {
        underpaidAmount > 0
    }
}

// MARK: - Decision View
struct AnalysisResultView: View {
    let analysis: PayslipAnalysis
    
    var body: some View {
        ZStack {
            if analysis.isUnderpaid {
                // Route to Splash Screen first
                UnderpaidView(
                    totalBeforeTax: analysis.totalBeforeTax,
                    underpaidAmount: analysis.underpaidAmount,
                    tax: analysis.tax,
                    superAmount: analysis.superAmount,
                    takeHome: analysis.takeHome
                )
                .transition(.opacity.combined(with: .scale))
                
            } else {
                // Route to Splash Screen first
                PaidRightView(
                    totalEarnings: analysis.totalBeforeTax,
                    tax: analysis.tax,
                    superAmount: analysis.superAmount,
                    takeHome: analysis.takeHome
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: analysis.isUnderpaid)
    }
}
