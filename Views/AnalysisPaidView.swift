import SwiftUI
import Charts

struct AnalysisPaidView: View {
    // MARK: - 1. DATA PARAMETERS
    let totalEarnings: Double
    let tax: Double
    let superAmount: Double
    let takeHome: Double
    
    // MARK: - 2. UI STATE & ANIMATIONS
    @State private var displayedAmount: Double = 0
    @State private var animateChart = false
    @State private var animateCard = false
    @State private var selectedCategory: String? = nil
    
    // MARK: - 3. CUSTOM COLORS
    let darkNavy = Color(red: 0.3, green: 0.28, blue: 0.45)
    let chartBlue = Color(red: 0.54, green: 0.62, blue: 0.93)
    let chartPurple = Color(red: 0.68, green: 0.48, blue: 0.78)
    let taxOrange = Color.orange
    
    // MARK: - 4. CHART DATA MODELS
    struct PayslipItem: Identifiable {
        var id: String { category }
        let category: String
        let amount: Double
        let color: Color
    }
    
    var chartData: [PayslipItem] {
        [
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
            Color.white.ignoresSafeArea()
            
            // MARK: Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: Top Header
                    HStack(spacing: 10) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 28))
                            .foregroundColor(chartPurple)
                        Text("Analysis")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(darkNavy)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // MARK: Salary Section
                    VStack(spacing: 8) {
                        Text("You Received")
                            .font(.title3)
                            .foregroundColor(darkNavy.opacity(0.7))
                        Text("$\(Int(displayedAmount))")
                            .font(.system(size: 50, weight: .black))
                            .foregroundColor(.black)
                        Text("From $\(Int(totalEarnings)) total earnings")
                            .foregroundColor(darkNavy.opacity(0.7))
                    }
                    
                    // MARK: Interactive Pie Chart
                    ZStack {
                        Chart(chartData) { item in
                            SectorMark(
                                angle: .value("Amount", animateChart ? item.amount : 0),
                                innerRadius: .ratio(0.6),
                                outerRadius: selectedCategory == item.category ? .ratio(1.0) : .ratio(0.9),
                                angularInset: 1.5
                            )
                            .cornerRadius(5)
                            .foregroundStyle(item.color)
                            .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.5)
                        }
                        .frame(height: 250)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedCategory)
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
                        
                        // Center Info Text
                        VStack(spacing: 2) {
                            if let selected = selectedCategory,
                               let item = chartData.first(where: { $0.category == selected }) {
                                Text("$\(Int(item.amount))")
                                    .font(.title).bold()
                                    .foregroundColor(item.color)
                                    .transition(.scale.combined(with: .opacity))
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                // Default State shows Take Home
                                Text("$\(Int(takeHome))")
                                    .font(.title).bold()
                                    .foregroundColor(chartBlue)
                                    .transition(.scale.combined(with: .opacity))
                                Text("Take Home")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .allowsHitTesting(false) // Ignore taps inside the center hole
                        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2)) { animateChart = true }
                        animateNumber()
                    }
                    
                    // MARK: Mathematical Breakdown Card
                    VStack(spacing: 18) {
                        row(title: "Total Before Tax Pay", value: totalEarnings, color: darkNavy, isHighlighted: false)
                        
                        Button(action: { selectCategory("Tax") }) {
                            row(title: "Taxes", value: -tax, color: taxOrange, isHighlighted: selectedCategory == "Tax")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { selectCategory("Super") }) {
                            row(title: "Superannuation", value: superAmount, color: chartPurple, isHighlighted: selectedCategory == "Super")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        Button(action: { selectCategory("Take Home") }) {
                            row(title: "Final Take Home", value: takeHome, color: chartBlue, bold: true, isHighlighted: selectedCategory == "Take Home")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(25)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .offset(y: animateCard ? 0 : 200)
                    .opacity(animateCard ? 1 : 0)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                            animateCard = true
                        }
                    }
                    
                    Spacer().frame(height: 180)
                }
            }
            .contentShape(Rectangle()) // Entire scroll area is now catchable
            .onTapGesture {
                withAnimation(.spring()) { selectedCategory = nil }
            }
            
            // 🔴 THE FIX: Duplicate Footer commented out so it doesn't overlap with ContentView 🔴
            /*
            // MARK: Footer
            VStack(spacing: 18) {
                HStack(spacing: 5) {
                    Text("Scroll down for more info").font(.subheadline).foregroundColor(.blue)
                    Image(systemName: "arrow.down").font(.caption).foregroundColor(.blue)
                }
                
                HStack(spacing: 20) {
                    footerButton(label: "Upload", icon: "square.and.arrow.up", color: .black)
                    footerButton(label: "Archive", icon: "doc.text", color: .blue)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 10)
            */
        }
    }
    
    // MARK: - 6. HELPER FUNCTIONS
    
    // Calculates which slice of the pie chart was tapped
    func handleTap(location: CGPoint, in geometry: GeometryProxy) {
        let radius = min(geometry.size.width, geometry.size.height) / 2
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        
        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // Match the innerRadius ratio (0.6) to create the dead zone
        if distance < (radius * 0.6) { return }
        
        var angle = atan2(dy, dx) + .pi / 2
        if angle < 0 { angle += 2 * .pi }
        
        let total = chartTotal
        var currentAngle: Double = 0
        for item in chartData {
            let itemAngle = (item.amount / total) * 2 * .pi
            if angle >= currentAngle && angle <= (currentAngle + itemAngle) {
                selectCategory(item.category)
                return
            }
            currentAngle += itemAngle
        }
    }

    // Triggers pie chart highlight
    func selectCategory(_ category: String) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedCategory = (selectedCategory == category) ? nil : category
        }
    }
    
    // Generates the rows for the breakdown card
    func row(title: String, value: Double, color: Color, bold: Bool = false, isHighlighted: Bool) -> some View {
        HStack {
            Text(title).font(.system(size: 16)).fontWeight(bold ? .bold : .medium).foregroundColor(darkNavy)
            Spacer()
            Text(String(format: "$%.2f", value)).foregroundColor(color).fontWeight(bold ? .bold : .medium)
        }
        .padding(.vertical, 6).padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(isHighlighted ? color.opacity(0.15) : Color.clear))
    }

    // Number counting up effect
    func animateNumber() {
        displayedAmount = 0
        let steps = 60
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (1.5 / Double(steps)) * Double(i)) {
                displayedAmount = min(takeHome, (takeHome / Double(steps)) * Double(i))
            }
        }
    }

    // (Footer logic kept for reference, but UI is commented out above)
    func footerButton(label: String, icon: String, color: Color) -> some View {
        Button(action: {}) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title3)
                Text(label).font(.caption).bold()
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(liquidGlassBackground)
        }
    }

    var liquidGlassBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
        }
    }
}

#Preview {
    AnalysisPaidView(
        totalEarnings: 565,
        tax: 56,
        superAmount: 61,
        takeHome: 435
    )
}
