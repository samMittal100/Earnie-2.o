import SwiftUI
import Charts

struct AnalysisUnderpaidInsightView: View {
    // MARK: - 1. DATA PARAMETERS
    let totalBeforeTax: Double
    let underpaidAmount: Double
    let tax: Double
    let superAmount: Double
    let takeHome: Double
    
    // MARK: - 2. UI STATE & ANIMATIONS
    @State private var displayedAmount: Double = 0
    @State private var animateChart = false
    @State private var selectedCategory: String? = nil
    @State private var showInteractivePayslip = false // Triggers the Jargon Buster sheet
    
    // MARK: - 3. CUSTOM COLORS
    let darkNavy = Color(red: 0.3, green: 0.28, blue: 0.45)
    let underpaidRed = Color(red: 0.95, green: 0.3, blue: 0.3)
    let chartBlue = Color(red: 0.54, green: 0.62, blue: 0.93)
    let chartPurple = Color(red: 0.68, green: 0.48, blue: 0.78)
    let taxOrange = Color.orange
    let warningPurple = Color(red: 0.38, green: 0.35, blue: 0.49)

    // MARK: - 4. CHART DATA MODELS
    struct PayslipItem: Identifiable {
        var id: String { category }
        let category: String
        let amount: Double
        let color: Color
    }
    
    var chartData: [PayslipItem] {
        [
            PayslipItem(category: "Underpaid", amount: underpaidAmount, color: underpaidRed),
            PayslipItem(category: "Tax", amount: tax, color: taxOrange),
            PayslipItem(category: "Super", amount: superAmount, color: chartPurple),
            PayslipItem(category: "Take Home", amount: takeHome, color: chartBlue)
        ]
    }
    
    var chartTotal: Double {
        chartData.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - 5. MAIN BODY
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: Background Layer
            Color(red: 0.96, green: 0.97, blue: 1.0)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring()) { selectedCategory = nil }
                }
            
            // MARK: Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    // MARK: Top Header
                    HStack {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 28))
                            .foregroundColor(chartPurple)
                        Text("Analysis")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(darkNavy)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // MARK: Received Summary
                    VStack(spacing: 5) {
                        Text("You Received")
                            .foregroundColor(.gray)
                        Text("$\(Int(displayedAmount))")
                            .font(.system(size: 48, weight: .black))
                        Text("From $\(Int(totalBeforeTax)) total earnings")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // MARK: Red Underpaid Banner
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Underpaid")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(Int(underpaidAmount))")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(warningPurple)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // MARK: Interactive Pie Chart
                    ZStack {
                        Chart(chartData) { item in
                            SectorMark(
                                angle: .value("Amount", animateChart ? item.amount : 0),
                                innerRadius: .ratio(0.65),
                                outerRadius: selectedCategory == item.category ? .ratio(1.05) : .ratio(1.0),
                                angularInset: 1.5
                            )
                            .foregroundStyle(item.color)
                            .cornerRadius(5)
                            .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.6)
                        }
                        .frame(height: 220)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedCategory)
                        .chartOverlay { proxy in
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(.clear)
                                    .contentShape(Circle())
                                    .onTapGesture { location in
                                        handleTap(location: location, in: geometry)
                                    }
                            }
                        }
                        
                        // Center Text of Pie Chart
                        VStack {
                            if let selected = selectedCategory,
                               let item = chartData.first(where: { $0.category == selected }) {
                                Text("$\(Int(item.amount))")
                                    .font(.title2).bold()
                                    .foregroundColor(item.color)
                                    .transition(.scale.combined(with: .opacity))
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                Text("$\(Int(takeHome))")
                                    .font(.title2).bold()
                                    .foregroundColor(chartBlue)
                                Text("Take Home")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .allowsHitTesting(false)
                    }
                    .onAppear { withAnimation(.easeInOut(duration: 1.0)) { animateChart = true } }
                    
                    // MARK: Earnie's Insight (Accessibility Upgrade)
                    HStack(alignment: .top, spacing: 15) {
                        Image("earnieMascot2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 3)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Earnie's Insight")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(darkNavy)
                            
                            Text("Your employer paid you for standard hours on Sunday. Based on your roster, you worked a 12-hour shift and are missing your Sunday Double Time penalty rates.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(Color(red: 0.92, green: 0.94, blue: 1.0))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    // MARK: Mathematical Breakdown Rows
                    VStack(spacing: 15) {
                        
                        // 1. THE ACTUAL PAYSLIP MATH
                        row(title: "Actual Gross Pay", value: totalBeforeTax, color: .black, isHighlighted: false)

                        Button(action: { selectCategory("Tax") }) {
                            row(title: "Taxes Withheld", value: -tax, color: taxOrange, isHighlighted: selectedCategory == "Tax")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        Button(action: { selectCategory("Take Home") }) {
                            row(title: "Final Take Home", value: takeHome, color: chartBlue, isBold: true, isHighlighted: selectedCategory == "Take Home")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 2. EARNIE'S INSIGHTS (Separated from the core math)
                        Divider()
                            .padding(.vertical, 5)
                        
                        Button(action: { selectCategory("Underpaid") }) {
                            row(title: "Missing Pay (Underpaid)", value: underpaidAmount, color: underpaidRed, isUnderpaidRow: true, isHighlighted: selectedCategory == "Underpaid")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { selectCategory("Super") }) {
                            row(title: "Super (Paid to Fund)", value: superAmount, color: chartPurple, isHighlighted: selectedCategory == "Super")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // MARK: The Jargon Buster Link
                    infoLinkSection
                    
                    // MARK: Contacts Section
                    contactsSection
                    
                    Spacer(minLength: 120)
                }
            }
        }
        .onAppear { animateNumber() }
    }

    // MARK: - 6. HELPER FUNCTIONS
    
    // Generates the rows for the breakdown card
    func row(title: String, value: Double, color: Color, isBold: Bool = false, isUnderpaidRow: Bool = false, isHighlighted: Bool) -> some View {
        HStack {
            Text(title).font(.system(size: 15, weight: isBold ? .bold : .medium))
            Spacer()
            Text(String(format: "$%.2f", value))
                .font(.system(size: 15, weight: isBold ? .bold : .medium))
                .foregroundColor(color)
        }
        .padding(8)
        .background(isHighlighted ? color.opacity(0.25) : (isUnderpaidRow ? color.opacity(0.12) : Color.clear))
        .cornerRadius(8)
    }

    // Triggers pie chart highlight
    func selectCategory(_ category: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedCategory = (selectedCategory == category) ? nil : category
        }
    }

    // Calculates which slice of the pie chart was tapped
    func handleTap(location: CGPoint, in geometry: GeometryProxy) {
        let radius = min(geometry.size.width, geometry.size.height) / 2
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // MODIFIED: Reset selection if clicking the center hole
        if distance < radius * 0.65 {
            withAnimation(.spring()) { selectedCategory = nil }
            return
        }
        
        var angle = atan2(dy, dx) + .pi / 2
        if angle < 0 { angle += 2 * .pi }
        let total = chartTotal
        var currentAngle: Double = 0
        for item in chartData {
            let itemAngle = (item.amount / total) * 2 * .pi
            if angle >= currentAngle && angle <= (currentAngle + itemAngle) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                selectCategory(item.category)
                return
            }
            currentAngle += itemAngle
        }
        
        // ADDED: Reset if no slice matched
        withAnimation(.spring()) { selectedCategory = nil }
    }

    // Interactive Payslip Button
    var infoLinkSection: some View {
        Button(action: {
            showInteractivePayslip = true
        }) {
            HStack {
                Image(systemName: "doc.viewfinder").foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("Jargon Buster").font(.subheadline).bold()
                    Text("Tap to view interactive payslip errors").font(.caption2).foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).stroke(Color.blue.opacity(0.3), lineWidth: 1.5))
            .background(Color.blue.opacity(0.05).cornerRadius(15))
        }
        .padding(.horizontal)
        .foregroundColor(.black)
        .sheet(isPresented: $showInteractivePayslip) {
            // Placeholder for sheet content (assumed existing in project)
            Text("Interactive Payslip View")
        }
    }

    // MARK: - CONTACTS SECTION (Uses the component defined below)
    var contactsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Contacts").font(.title2).bold().padding(.horizontal)
            ContactsSlider()
        }
    }

    // Number counting up effect
    func animateNumber() {
        displayedAmount = 0
        withAnimation(.linear(duration: 1.0)) { displayedAmount = takeHome }
    }
}

// MARK: - PREVIEW
#Preview {
    AnalysisUnderpaidInsightView(
        totalBeforeTax: 978.72,
        underpaidAmount: 164.78,
        tax: 248.00,
        superAmount: 100.18,
        takeHome: 730.72
    )
}

