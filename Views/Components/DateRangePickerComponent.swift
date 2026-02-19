import SwiftUI

struct DateRangePickerComponent: View {
    // MARK: - 1. DATA BINDINGS
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    // MARK: - 2. UI STATE
    @State private var showPickerSheet = false
    
    // 🔴 NEW: Tracks if the user has actually hit 'Apply'
    @State private var hasSelectedDates = false
    
    // MARK: - 3. FORMATTER LOGIC
    var formattedRange: String {
        if hasSelectedDates {
            // Show the real dates once applied
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            return "\(formatter.string(from: startDate))  →  \(formatter.string(from: endDate))"
        } else {
            // Show the placeholder by default
            return "dd/mm/yyyy  →  dd/mm/yyyy"
        }
    }
    
    // MARK: - 4. MAIN BODY
    var body: some View {
        
        // MARK: The "One Big Box" Button
        Button(action: {
            showPickerSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                
                Text(formattedRange)
                    .font(.system(size: 15, weight: .semibold))
                    // Grays out the text if it's the placeholder, makes it black if it's active
                    .foregroundColor(hasSelectedDates ? .primary : .gray.opacity(0.6))
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(14)
        }
        
        // MARK: The Sliding Half-Sheet
        .sheet(isPresented: $showPickerSheet) {
            VStack(spacing: 24) {
                Text("Select Date Range")
                    .font(.headline)
                    .padding(.top, 10)
                
                // Native Pickers contained in a clean card
                VStack(spacing: 16) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .tint(Color(red: 0.58, green: 0.69, blue: 0.95))
                    
                    Divider()
                    
                    // The 'in: startDate...' prevents picking an end date before the start date
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .tint(Color(red: 0.58, green: 0.69, blue: 0.95))
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Spacer()
                
                // MARK: Apply Button
                Button("Apply") {
                    // 🔴 NEW: Flips the flag to true so the text updates
                    hasSelectedDates = true
                    showPickerSheet = false
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.58, green: 0.69, blue: 0.95))
                .cornerRadius(14)
            }
            .padding(24)
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
        }
    }
}
