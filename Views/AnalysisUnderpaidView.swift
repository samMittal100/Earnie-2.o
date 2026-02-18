import SwiftUI
import Charts

struct AnalysisUnderpaidView: View {
    // MARK: - Payslip Data
    let totalBeforeTax: Double
        let underpaidAmount: Double
        let tax: Double
        let superAmount: Double
        let takeHome: Double
    
    // MARK: - State for Animations
    @State private var displayedAmount: Double = 0
    @State private var animateChart = false
    @State private var selectedCategory: String? = nil
    
    // MARK: - Custom Colors
    let darkNavy = Color(red: 0.3, green: 0.28, blue: 0.45)
    let underpaidRed = Color(red: 0.95, green: 0.3, blue: 0.3)
    let chartBlue = Color(red: 0.54, green: 0.62, blue: 0.93)
    let chartPurple = Color(red: 0.68, green: 0.48, blue: 0.78)
    let taxOrange = Color.orange
    let warningPurple = Color(red: 0.38, green: 0.35, blue: 0.49)

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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: - BACKGROUND LAYER
            // The tap gesture is applied here so it doesn't block buttons/links
            Color(red: 0.96, green: 0.97, blue: 1.0)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring()) { selectedCategory = nil }
                }
            
            // MARK: - SCROLLABLE CONTENT
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // MARK: Header
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
                    
                    // MARK: Underpaid Banner
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
                    
                    // MARK: - Breakdown Rows
                    VStack(spacing: 15) {
                        row(title: "Total Before Tax Pay", value: totalBeforeTax, color: .black, isHighlighted: false)
                        
                        Button(action: { selectCategory("Underpaid") }) {
                            row(title: "Underpaid", value: -underpaidAmount, color: underpaidRed, isUnderpaidRow: true, isHighlighted: selectedCategory == "Underpaid")
                        }
                        .buttonStyle(PlainButtonStyle())

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
                            row(title: "Final Take Home", value: takeHome, color: chartBlue, isBold: true, isHighlighted: selectedCategory == "Take Home")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    infoLinkSection
                    contactsSection
                    Spacer(minLength: 120)
                }
            }
            // IMPORTANT: Removed .contentShape() and .onTapGesture() from ScrollView
            
            // MARK: - FOOTER
            VStack(spacing: 18) {
                HStack(spacing: 5) {
                    Text("Scroll down for more info").font(.subheadline).foregroundColor(.blue)
                    Image(systemName: "arrow.down").font(.caption).foregroundColor(.blue)
                }
                footerButtons
            }
            .padding(.bottom, 10)
        }
        .onAppear { animateNumber() }
    }

    // MARK: - Helper Functions
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

    func selectCategory(_ category: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedCategory = (selectedCategory == category) ? nil : category
        }
    }

    func handleTap(location: CGPoint, in geometry: GeometryProxy) {
        let radius = min(geometry.size.width, geometry.size.height) / 2
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = sqrt(dx*dx + dy*dy)
        if distance < radius * 0.65 { return }
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
    }

    var infoLinkSection: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "questionmark.circle").foregroundColor(.red)
                VStack(alignment: .leading) {
                    Text("Why was money taken").font(.subheadline).bold()
                    Text("Tap here to learn more").font(.caption2).foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.white)
            }
            .padding().background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.3)))
        }.padding(.horizontal).foregroundColor(.black)
    }

    var contactsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Contacts").font(.title2).bold().padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ContactCard(name: "Fair Work", link: "fairwork.gov.au", phone: "13 13 94")
                    ContactCard(name: "ATO", link: "ato.gov.au", phone: "13 28 61")
                }.padding(.horizontal)
            }
        }
    }

    func animateNumber() {
        displayedAmount = 0
        withAnimation(.linear(duration: 1.0)) { displayedAmount = takeHome }
    }
    
    var footerButtons: some View {
        HStack(spacing: 20) {
            footerButton(label: "Upload", icon: "square.and.arrow.up", color: .black)
            footerButton(label: "Archive", icon: "doc.text", color: .blue)
        }.padding(.horizontal, 20)
    }
    
    func footerButton(label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
            Text(label).font(.caption).bold()
        }
        .foregroundColor(color).frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(liquidGlassBackground).cornerRadius(20)
    }

    var liquidGlassBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
    }
}

// MARK: - CONTACT CARD FIXED
struct ContactCard: View {
    let name: String
    let link: String
    let phone: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name)
                .font(.headline)
                .foregroundColor(.black)

            // WEBSITE LINK (Safely handles spaces)
            let safeLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
            if let url = URL(string: "https://\(safeLink)") {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "globe")
                        Text(link)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            // PHONE LINK
            let cleanNumber = phone.replacingOccurrences(of: " ", with: "")
            if let phoneURL = URL(string: "tel://\(cleanNumber)") {
                Link(destination: phoneURL) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text(phone)
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }
        }
        .padding()
        .frame(width: 160, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    AnalysisUnderpaidView(
        totalBeforeTax: 565,
        underpaidAmount: 106,
        tax: 56,
        superAmount: 61,
        takeHome: 435
    )
}
