import SwiftUI
import Charts

struct AnalysisUnderpaidInsightView: View {
    // MARK: - Payslip Data
    let totalBeforeTax: Double
    let underpaidAmount: Double
    let tax: Double
    let superAmount: Double
    let takeHome: Double
    
    // MARK: - State for Animations & Sheets
    @State private var displayedAmount: Double = 0
    @State private var animateChart = false
    @State private var selectedCategory: String? = nil
    @State private var showInteractivePayslip = false // Triggers the Jargon Buster sheet
    
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
                    
                    // MARK: - EARNIE's INSIGHT (THE ACCESSIBILITY UPGRADE)
                    HStack(alignment: .top, spacing: 15) {
                        Image("earnieMascot2") // Ensure this exactly matches your asset name
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
                            
                            // Purely informational, translating math to English
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
                    
                    // 🔴 MARK: - THE JARGON BUSTER LINK 🔴
                    infoLinkSection
                    
                    contactsSection
                    Spacer(minLength: 120)
                }
            }
            
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

    // 🔴 NEW: The Interactive Payslip Button 🔴
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
            // This calls the InteractivePayslipView.swift file
            InteractivePayslipView()
        }
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

// Ensure ContactCard is only declared ONCE in your project.
// If it's already in your other file, delete it from here to avoid "Invalid redeclaration" errors.

#Preview {
    AnalysisUnderpaidInsightView(
        totalBeforeTax: 978.72,
        underpaidAmount: 164.78,
        tax: 248.00,
        superAmount: 100.18,
        takeHome: 730.72
    )
}
