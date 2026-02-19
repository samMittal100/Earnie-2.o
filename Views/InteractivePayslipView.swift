import SwiftUI

// MARK: - 1. DATA MODEL
struct JargonItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let xPct: Double // Center X
    let yPct: Double // Center Y
    let wPct: Double // Width of the highlight box
    let hPct: Double // Height of the highlight box
    let isError: Bool
}

// MARK: - 2. MAIN VIEW
struct InteractivePayslipView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedJargon: JargonItem? = nil
    @State private var isPulsing = false
    
    // MARK: - 3. HOTSPOT DATA
    let hotspots: [JargonItem] = [
        JargonItem(
            title: "CAS Normal Time",
            description: "This is your standard base hourly rate as a Casual worker. It does not include any weekend, public holiday, or late-night penalty rates.",
            xPct: 0.13, yPct: 0.328, wPct: 0.22, hPct: 0.025,
            isError: false
        ),
        JargonItem(
            title: "PAYG Tax",
            description: "PAYG stands for 'Pay As You Go'. This is the tax your employer automatically deducts from your wage and sends directly to the ATO.",
            xPct: 0.10, yPct: 0.500, wPct: 0.16, hPct: 0.025,
            isError: false
        ),
        JargonItem(
            title: "Superannuation (Host Plus)",
            description: "Your Super. By law, your employer must pay an additional percentage of your earnings into this fund. It is not deducted from your take-home pay.",
            xPct: 0.13, yPct: 0.590, wPct: 0.22, hPct: 0.025,
            isError: false
        ),
        // THE RED ERROR HOTSPOT
        JargonItem(
            title: "Missing Sunday Hours",
            description: "ERROR FOUND: Your roster shows you worked a 12-hour double shift on Sunday. However, this line item only pays you for 7.6 hours. You are missing 4.4 hours of Double Time pay.",
            xPct: 0.90, yPct: 0.437, wPct: 0.15, hPct: 0.025,
            isError: true
        )
    ]
    
    let darkNavy = Color(red: 0.3, green: 0.28, blue: 0.45)
    
    // MARK: - 4. MAIN BODY
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 1.0).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        Text("Tap the highlighted boxes to translate payroll jargon into plain English.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // MARK: The Payslip Canvas
                        Image("Payslip_demo")
                            .resizable()
                            .scaledToFit()
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding()
                            .overlay(
                                GeometryReader { geo in
                                    ZStack(alignment: .topLeading) {
                                        
                                        // The Highlighter Boxes
                                        ForEach(hotspots) { item in
                                            Button(action: {
                                                selectedJargon = item
                                            }) {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill((item.isError ? Color.red : Color.blue).opacity(isPulsing ? 0.25 : 0.1))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(item.isError ? Color.red : Color.blue, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                                                    )
                                            }
                                            .frame(
                                                width: geo.size.width * item.wPct,
                                                height: geo.size.height * item.hPct
                                            )
                                            .position(
                                                x: geo.size.width * item.xPct,
                                                y: geo.size.height * item.yPct
                                            )
                                        }
                                    }
                                }
                                .padding()
                            )
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Jargon Buster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            // MARK: The Plain English Bottom Sheet
            .sheet(item: $selectedJargon) { jargon in
                JargonExplanationSheet(jargon: jargon)
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - 5. EXPLANATION SHEET COMPONENT
struct JargonExplanationSheet: View {
    let jargon: JargonItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: jargon.isError ? "exclamationmark.triangle.fill" : "info.circle.fill")
                    .foregroundColor(jargon.isError ? .red : .blue)
                    .font(.title2)
                
                Text(jargon.title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(red: 0.3, green: 0.28, blue: 0.45))
            }
            
            Text(jargon.description)
                .font(.body)
                .foregroundColor(.gray)
                .lineSpacing(6)
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 10)
    }
}

#Preview {
    InteractivePayslipView()
}
