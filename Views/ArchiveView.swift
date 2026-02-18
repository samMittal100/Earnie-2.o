import SwiftUI

struct ArchiveView: View {
    // Colors pulled from the prototype
    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98)
    let darkNavy = Color(red: 0.05, green: 0.2, blue: 0.3)
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Top Nav (Viewfinder Icon)
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "viewfinder")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.top, 10)
                    
                    // MARK: - Header
                    Text("Archives")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(darkNavy)
                    
                    // MARK: - Filter Pills
                    HStack(spacing: 12) {
                        FilterPill(title: "Date")
                        FilterPill(title: "Month")
                        FilterPill(title: "Year")
                    }
                    .padding(.bottom, 10)
                    
                    // MARK: - January Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("January")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ArchiveRow(
                            dateRange: "1st - 15th",
                            total: "$354",
                            isUnderpaid: true // Red text for underpaid
                        )
                        
                        ArchiveRow(
                            dateRange: "15th - 30th",
                            total: "$235",
                            isUnderpaid: false
                        )
                    }
                    .padding(.bottom, 10)
                    
                    // MARK: - February Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("February")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ArchiveRow(
                            dateRange: "1st - 15th",
                            total: "$354",
                            isUnderpaid: true // Red text
                        )
                        
                        ArchiveRow(
                            dateRange: "15th - 2nd",
                            total: "$235",
                            isUnderpaid: false
                        )
                    }
                    
                    // Bottom spacing for the Glass Tab Bar
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Custom Sub-Components for Archive

struct FilterPill: View {
    var title: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
            Text(title)
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.gray)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}

struct ArchiveRow: View {
    var dateRange: String
    var total: String
    var isUnderpaid: Bool
    
    let primaryBlue = Color(red: 0.58, green: 0.69, blue: 0.95)
    let darkRed = Color(red: 0.7, green: 0.2, blue: 0.3)
    
    var body: some View {
        Button(action: {
            print("Tapped \(dateRange)")
        }) {
            HStack(spacing: 16) {
                // Left Icon (Clipboard)
                Image(systemName: "list.clipboard")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                // Text Stack
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateRange)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Total : \(total)")
                        .font(.system(size: 13, weight: .medium))
                        // Changes color based on underpaid status per the prototype
                        .foregroundColor(isUnderpaid ? darkRed : .white.opacity(0.8))
                }
                
                Spacer()
                
                // Right Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .frame(height: 80)
            .background(primaryBlue)
            .cornerRadius(24) // Pill-shaped curve
        }
    }
}

#Preview {
    ArchiveView()
}
