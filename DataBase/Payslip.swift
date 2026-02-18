import SwiftData
import Foundation

@Model
class Payslip {
    var id: UUID
    var uploadDate: Date
    var employerName: String
    var grossPay: Double
    var netPay: Double
    var tax: Double              // Added for Methangi's Chart
    var superannuation: Double   // Added for Methangi's Chart
    var isUnderpaid: Bool
    
    init(employerName: String, grossPay: Double, netPay: Double, tax: Double, superannuation: Double, isUnderpaid: Bool) {
        self.id = UUID()
        self.uploadDate = Date()
        self.employerName = employerName
        self.grossPay = grossPay
        self.netPay = netPay
        self.tax = tax
        self.superannuation = superannuation
        self.isUnderpaid = isUnderpaid
    }
}
