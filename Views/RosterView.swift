import SwiftUI
import Combine

// MARK: - Enums
enum CalendarMode: String, CaseIterable {
    case week = "Week"
    case month = "Month"
}

// MARK: - Model
struct Shift: Identifiable, Equatable {
    let id = UUID()
    var date: Date
    var startTime: Date
    var endTime: Date
    var breakDurationMinutes: Double = 30
    
    var durationHours: Double {
        let raw = endTime.timeIntervalSince(startTime)
        let afterBreak = raw - (breakDurationMinutes * 60)
        return max(0, afterBreak / 3600)
    }
}

// MARK: - ViewModel
class RosterViewModel: ObservableObject {
    
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var shifts: [Shift] = []
    
    // UI State
    @Published var editingShift: Shift?
    @Published var isRosterUploaded: Bool = false
    @Published var calendarMode: CalendarMode = .month
    
    // MARK: - Roster Logic
        func loadMockRoster() {
            let calendar = Calendar.current
            let today = Date()
            
            // Ensure we work with the current week relative to today for the mock
            guard let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
                  let tuesday = calendar.date(byAdding: .day, value: 1, to: monday),
                  let saturday = calendar.date(byAdding: .day, value: 5, to: monday),
                  let sunday = calendar.date(byAdding: .day, value: 6, to: monday)
            else { return }
            
            // FAKE DATA ALIGNED WITH THE DEMO STORY
            shifts = [
                Shift(date: monday,
                      startTime: setTime(for: monday, hour: 8, minute: 30),
                      endTime: setTime(for: monday, hour: 17),
                      breakDurationMinutes: 30),
                
                Shift(date: tuesday,
                      startTime: setTime(for: tuesday, hour: 8, minute: 30),
                      endTime: setTime(for: tuesday, hour: 17),
                      breakDurationMinutes: 30),
                
                Shift(date: saturday,
                      startTime: setTime(for: saturday, hour: 8, minute: 30),
                      endTime: setTime(for: saturday, hour: 17),
                      breakDurationMinutes: 30),
                
                // THE MASSIVE DOUBLE SHIFT (The source of the "underpayment")
                Shift(date: sunday,
                      startTime: setTime(for: sunday, hour: 8, minute: 0),
                      endTime: setTime(for: sunday, hour: 20, minute: 30), // 8:30 PM
                      breakDurationMinutes: 60)
            ]
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isRosterUploaded = true
                // Set selected date to the Sunday shift so it's instantly visible
                selectedDate = sunday
            }
        }
    
    func updateShift(_ updated: Shift) {
        if let index = shifts.firstIndex(where: { $0.id == updated.id }) {
            // Check if the date changed (in case we want to support moving shifts across days later)
            // For now, we update the existing index
            withAnimation {
                shifts[index] = updated
            }
        }
    }
    
    // MARK: - Helpers
    private func setTime(for date: Date, hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
    
    func shiftsForWeek(of date: Date) -> [Shift] {
        let calendar = Calendar.current
        
        guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)),
              let end = calendar.date(byAdding: .day, value: 7, to: start)
        else { return [] }
        
        return shifts
            .filter { $0.date >= start && $0.date < end }
            .sorted { $0.date < $1.date }
    }
    
    func totalHoursForWeek(of date: Date) -> Double {
        shiftsForWeek(of: date).reduce(0) { $0 + $1.durationHours }
    }
    
    func hasShift(on date: Date) -> Bool {
        let calendar = Calendar.current
        return shifts.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getShift(on date: Date) -> Shift? {
        let calendar = Calendar.current
        return shifts.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

// MARK: - Main View
struct RosterView: View {
    
    @StateObject private var viewModel = RosterViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Roster")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.4))
                    
                    Spacer()
                    
                    Button {
                        viewModel.loadMockRoster()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .symbolEffect(.bounce, value: viewModel.isRosterUploaded)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        CalendarCardView(viewModel: viewModel)
                            .padding(.horizontal)
                        
                        if viewModel.isRosterUploaded {
                            SummarySection(viewModel: viewModel)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            VStack(spacing: 15) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Text("Upload a roster to see your summary")
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        // Advanced Bottom Sheet
        .sheet(item: $viewModel.editingShift) { shift in
            AdvancedShiftEditView(shift: shift) { updated in
                viewModel.updateShift(updated)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Calendar Card
struct CalendarCardView: View {
    
    @ObservedObject var viewModel: RosterViewModel
    let calendar = Calendar.current
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 15) {
            
            HStack {
                Text(viewModel.currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Week / Month Toggle
                Picker("View Mode", selection: $viewModel.calendarMode) {
                    ForEach(CalendarMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            
            // Weekday Headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Dynamic Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                
                ForEach(visibleDays(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, viewModel: viewModel)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedDate = date
                                    
                                    // If a shift exists, open the sheet
                                    if let shift = viewModel.getShift(on: date) {
                                        viewModel.editingShift = shift
                                    }
                                }
                            }
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.calendarMode)
            .frame(height: viewModel.calendarMode == .week ? 60 : 280, alignment: .top)
            .clipped() // Ensure smooth transition cropping
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // Subview for Day Cell to keep logic clean
    struct DayCell: View {
        let date: Date
        @ObservedObject var viewModel: RosterViewModel
        let calendar = Calendar.current
        
        var isSelected: Bool {
            calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        }
        
        var body: some View {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.clear)
                    )
                
                // Shift Dot Indicator
                if viewModel.hasShift(on: date) {
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.3) : Color.blue)
                        .frame(width: 5, height: 5)
                        .transition(.scale)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 45)
        }
    }
    
    // Logic to switch between full month days and just the selected week
    func visibleDays() -> [Date?] {
        switch viewModel.calendarMode {
        case .month:
            return daysInMonth()
        case .week:
            return daysInSelectedWeek()
        }
    }
    
    func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: viewModel.currentMonth),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.currentMonth))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: first)
        let offset = (firstWeekday + 5) % 7 // Adjust based on locale start day (Assuming Mon start here approx)
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for i in 0..<range.count {
            days.append(calendar.date(byAdding: .day, value: i, to: first))
        }
        return days
    }
    
    func daysInSelectedWeek() -> [Date?] {
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: viewModel.selectedDate)) else { return [] }
        
        // Assuming Monday start for consistency with mock data, adjust offset if needed
        var days: [Date?] = []
        for i in 0..<7 {
            days.append(calendar.date(byAdding: .day, value: i, to: startOfWeek))
        }
        return days
    }
}

// MARK: - Summary Section
struct SummarySection: View {
    
    @ObservedObject var viewModel: RosterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Summary")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.4))
                    
                    Text("This Week")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(String(format: "%.1f hrs", viewModel.totalHoursForWeek(of: viewModel.selectedDate)))
                    .font(.title)
                    .bold()
                    .foregroundColor(.blue)
                    .contentTransition(.numericText())
            }
            .padding(.bottom, 5)
            
            VStack(spacing: 12) {
                let shifts = viewModel.shiftsForWeek(of: viewModel.selectedDate)
                
                if shifts.isEmpty {
                    Text("No shifts this week")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(shifts) { shift in
                        Button {
                            viewModel.editingShift = shift
                        } label: {
                            ShiftListRow(shift: shift)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// MARK: - Shift Row (Preserved)
struct ShiftListRow: View {
    let shift: Shift
    var body: some View {
        HStack {
            Text(shift.date.formatted(.dateTime.weekday(.abbreviated)))
                .bold()
                .frame(width: 50, alignment: .leading)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading) {
                Text("\(shift.startTime.formatted(date: .omitted, time: .shortened)) - \(shift.endTime.formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                if shift.breakDurationMinutes > 0 {
                    Text("Break: \(Int(shift.breakDurationMinutes))m")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Text(String(format: "%.1f h", shift.durationHours))
                .bold()
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(red: 0.97, green: 0.97, blue: 0.99))
        .cornerRadius(12)
    }
}

// MARK: - Advanced Bottom Sheet
struct AdvancedShiftEditView: View {
    
    @State var shift: Shift
    var onSave: (Shift) -> Void
    @Environment(\.dismiss) var dismiss
    
    // Local State for Sliders (0.0 - 24.0)
    @State private var startHour: Double = 9.0
    @State private var endHour: Double = 17.0
    @State private var breakDuration: Double = 30.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // 1. Timeline Visualization
                    TimelineView(startHour: startHour, endHour: endHour, breakDuration: breakDuration)
                        .frame(height: 80)
                        .padding(.top, 20)
                    
                    // 2. Calculated Stats
                    HStack(spacing: 40) {
                        StatView(title: "Duration", value: String(format: "%.1f h", calculateDuration()))
                        StatView(title: "Earnings", value: "Est. $--") // Placeholder for future feature
                    }
                    
                    Divider()
                    
                    // 3. Sliders
                    VStack(spacing: 25) {
                        ControlRow(icon: "clock", title: "Start Time", value: formatTime(hour: startHour)) {
                            Slider(value: $startHour, in: 0...23.9, step: 0.25)
                                .onChange(of: startHour) { _ in updateShiftModel() }
                        }
                        
                        ControlRow(icon: "clock.fill", title: "End Time", value: formatTime(hour: endHour)) {
                            Slider(value: $endHour, in: 0...23.9, step: 0.25)
                                .onChange(of: endHour) { _ in updateShiftModel() }
                        }
                        
                        ControlRow(icon: "cup.and.saucer.fill", title: "Break", value: "\(Int(breakDuration)) min") {
                            Slider(value: $breakDuration, in: 0...120, step: 5)
                                .onChange(of: breakDuration) { _ in updateShiftModel() }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(red: 0.98, green: 0.98, blue: 1.0))
            .navigationTitle("Edit Shift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(shift)
                        dismiss()
                    }
                    .bold()
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Initialize sliders from passed Shift model
                loadFromModel()
            }
        }
    }
    
    // MARK: - Logic
    
    func loadFromModel() {
        let calendar = Calendar.current
        let startComp = calendar.dateComponents([.hour, .minute], from: shift.startTime)
        let endComp = calendar.dateComponents([.hour, .minute], from: shift.endTime)
        
        startHour = Double(startComp.hour ?? 0) + Double(startComp.minute ?? 0) / 60.0
        endHour = Double(endComp.hour ?? 0) + Double(endComp.minute ?? 0) / 60.0
        breakDuration = shift.breakDurationMinutes
    }
    
    func updateShiftModel() {
        // Enforce End > Start logic visually
        if endHour < startHour { endHour = startHour }
        
        shift.startTime = dateFromHour(startHour)
        shift.endTime = dateFromHour(endHour)
        shift.breakDurationMinutes = breakDuration
    }
    
    func dateFromHour(_ value: Double) -> Date {
        let hour = Int(value)
        let minute = Int((value - Double(hour)) * 60)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: shift.date) ?? shift.date
    }
    
    func formatTime(hour: Double) -> String {
        let date = dateFromHour(hour)
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    func calculateDuration() -> Double {
        let raw = (endHour - startHour)
        let afterBreak = raw - (breakDuration / 60)
        return max(0, afterBreak)
    }
}

// MARK: - Components for Bottom Sheet

struct TimelineView: View {
    var startHour: Double
    var endHour: Double
    var breakDuration: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background Track (0-24h)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 40)
                
                // Hour Markers
                HStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Text("\(i * 6)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .offset(y: 35)
                
                // Working Block (Blue)
                let widthPerOneHour = geo.size.width / 24.0
                let startX = startHour * widthPerOneHour
                let blockWidth = max(0, (endHour - startHour) * widthPerOneHour)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                    
                    // Break Visualization (Striped or different color overlay)
                    if breakDuration > 0 {
                        let breakWidth = (breakDuration / 60.0) * widthPerOneHour
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange.opacity(0.8))
                            .frame(width: min(breakWidth, blockWidth), height: 20)
                            .overlay(
                                Text("Break")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(breakWidth > 30 ? 1 : 0) // Hide text if too small
                            )
                    }
                }
                .frame(width: blockWidth, height: 40)
                .offset(x: startX)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: startHour)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: endHour)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: breakDuration)
            }
        }
    }
}

struct ControlRow<Content: View>: View {
    let icon: String
    let title: String
    let value: String
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.4))
                Spacer()
                Text(value)
                    .font(.body.monospacedDigit())
                    .bold()
                    .foregroundColor(.blue)
            }
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .textCase(.uppercase)
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
struct RosterView_Previews: PreviewProvider {
    static var previews: some View {
        RosterView()
    }
}
