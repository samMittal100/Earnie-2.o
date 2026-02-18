import SwiftUI

struct ArchiveView: View {
    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98)
    let darkNavy = Color(red: 0.05, green: 0.2, blue: 0.3)
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Top Nav (Viewfinder Icon)
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Open Scanner")
                        }) {
                            Image(systemName: "viewfinder")
                                .font(.title2)
                                .foregroundColor(darkNavy)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.top, 20) // Fixed clipping issue
                    
                    // MARK: - Header
                    Text("Archives")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(darkNavy)
                    
                    // MARK: - Native Date Range Filter (Cleaned Up)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Filter by Date")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 30) {
                            // "From" Date Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("FROM").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .tint(primaryBlue) // Brands the calendar pop-up
                            }
                            
                            // "To" Date Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("TO").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .tint(primaryBlue) // Brands the calendar pop-up
                            }
                            
                            Spacer() // Pushes them neatly to the left
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // MARK: - January Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("January")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ArchiveRow(dateRange: "1st - 15th", total: "$354", isUnderpaid: true)
                        ArchiveRow(dateRange: "15th - 30th", total: "$235", isUnderpaid: false)
                    }
                    .padding(.bottom, 10)
                    
                    // MARK: - February Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("February")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ArchiveRow(dateRange: "1st - 15th", total: "$354", isUnderpaid: true)
                        ArchiveRow(dateRange: "15th - 2nd", total: "$235", isUnderpaid: false)
                    }
                    
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Archive Row Component
struct ArchiveRow: View {
    var dateRange: String
    var total: String
    var isUnderpaid: Bool
    
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    let darkRed = Color(red: 0.7, green: 0.2, blue: 0.3)
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: "list.clipboard")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateRange)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Total : \(total)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isUnderpaid ? darkRed : .white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .frame(height: 80)
            .background(primaryBlue)
            .cornerRadius(24)
        }
    }
}

#Preview {
    ArchiveView()
}
