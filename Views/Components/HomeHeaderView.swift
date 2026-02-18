import SwiftUI

struct HomeHeaderView: View {
    // MARK: - 1. PROPERTIES
    let name: String
    
    // MARK: - 2. MAIN BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hi, \(name)")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Color(red: 0.35, green: 0.32, blue: 0.45)) // Prototype dark purple
            
            Text("Get started with the first step.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.gray)
        }
    }
}
