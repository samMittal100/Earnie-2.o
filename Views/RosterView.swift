import SwiftUI
import Combine

// MARK: - 1. ENUMS & MODELS
enum CalendarMode: String, CaseIterable {
    case week = "Week"
    case fortnight = "Fortnight"
    case month = "Month"
}

struct Shift: Identifiable, Equatable {
    let id = UUID()
    var date: Date
    var startTime: Date
    var endTime: Date
    var breakDurationMinutes: Double = 30
    var overtimeMinutes: Double = 0
    
    var durationHours: Double {
        let raw = endTime.timeIntervalSince(startTime)
        let afterBreak = raw - (breakDurationMinutes * 60)
        let total = afterBreak + (overtimeMinutes * 60)
        return max(0, total / 3600)
    }
}

// MARK: - 2. VIEW MODEL (LOGIC)
class RosterViewModel: ObservableObject {
    
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var shifts: [Shift] = []
    
    // UI State
    @Published var editingShift: Shift?
    @Published var calendarMode: CalendarMode = .month
    
    // MARK: - Roster Logic
    func loadMockRoster() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let wednesday = calendar.date(byAdding: .day, value: 2, to: monday),
              let friday = calendar.date(byAdding: .day, value: 4, to: monday),
              let saturday = calendar.date(byAdding: .day, value: 5, to: monday)
        else { return }
        
        shifts = [
            Shift(date: monday,
                  startTime: setTime(for: monday, hour: 9),
                  endTime: setTime(for: monday, hour: 17),
                  breakDurationMinutes: 60,
                  overtimeMinutes: 0),
            
            Shift(date: wednesday,
                  startTime: setTime(for: wednesday, hour: 10, minute: 30),
                  endTime: setTime(for: wednesday, hour: 15),
                  breakDurationMinutes: 15,
                  overtimeMinutes: 30),
            
            Shift(date: friday,
                  startTime: setTime(for: friday, hour: 8),
                  endTime: setTime(for: friday, hour: 16),
                  breakDurationMinutes: 45,
                  overtimeMinutes: 0),
            
            Shift(date: saturday,
                  startTime: setTime(for: saturday, hour: 12),
                  endTime: setTime(for: saturday, hour: 20),
                  breakDurationMinutes: 30,
                  overtimeMinutes: 60)
        ]
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if let firstShift = shifts.first {
                selectedDate = firstShift.date
            }
        }
    }
    
    func updateShift(_ updated: Shift) {
        if let index = shifts.firstIndex(where: { $0.id == updated.id }) {
            withAnimation {
                shifts[index] = updated
            }
        }
    }
    
    func deleteShift(_ shift: Shift) {
        withAnimation {
            shifts.removeAll { $0.id == shift.id }
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

// MARK: - 3. MAIN VIEW
struct RosterView: View {
    
    @StateObject private var viewModel = RosterViewModel()
    @Environment(\.dismiss) var dismiss // Needed for the Confirm button
    
    // Consistent App Background Color
    let appBackground = Color(red: 243/255, green: 241/255, blue: 247/255)
    
    var body: some View {
        ZStack { // 🔴 Removed 'alignment: .bottom' since we aren't floating anymore
            
            // 1. Background
            appBackground.ignoresSafeArea()
            
            // 2. Main Content
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Roster")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.4))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 15)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        
                        CalendarCardView(viewModel: viewModel)
                            .padding(.horizontal)
                        
                        // Summary Section
                        SummarySection(viewModel: viewModel)
                        
                        // 🔴 THE FIX: The Button is now INSIDE the scroll view.
                        // It stays static at the bottom of the content and scrolls with the screen.
                        Button(action: {
                            dismiss() // Sends user back to HomeView
                        }) {
                            Text("Confirm Roster")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .cornerRadius(16)
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        // 🔴 This extra space ensures the button can scroll completely past your global Tab Bar
                        Spacer(minLength: 120)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        // Instantly populates the data the moment the screen opens
        .onAppear {
            viewModel.loadMockRoster()
        }
        // Advanced Bottom Sheet
        .sheet(item: $viewModel.editingShift) { shift in
            AdvancedShiftEditView(
                shift: shift,
                onSave: { updated in
                    viewModel.updateShift(updated)
                },
                onDelete: {
                    viewModel.deleteShift(shift)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - 4. CALENDAR COMPONENTS
struct CalendarCardView: View {
    @ObservedObject var viewModel: RosterViewModel
    let calendar = Calendar.current
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 15) {
            
            HStack {
                // Month & Year Dropdown
                HStack(spacing: 8) {
                    Menu {
                        ForEach(1...12, id: \.self) { month in
                            Button {
                                updateMonth(month)
                            } label: {
                                Text(Calendar.current.monthSymbols[month - 1])
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(viewModel.currentMonth.formatted(.dateTime.month(.wide)))
                                .font(.headline)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Menu {
                        ForEach(2023...2030, id: \.self) { year in
                            Button {
                                updateYear(year)
                            } label: {
                                Text(String(format: "%d", year))
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(viewModel.currentMonth.formatted(.dateTime.year()))
                                .font(.headline)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .fixedSize()
                
                Spacer()
                
                // Week / Fortnight / Month Toggle
                Picker("View Mode", selection: $viewModel.calendarMode) {
                    ForEach(CalendarMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
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
            .frame(height: heightForMode(), alignment: .top)
            .clipped()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // Helpers
    func updateMonth(_ month: Int) {
        var components = calendar.dateComponents([.year, .month, .day], from: viewModel.currentMonth)
        components.month = month
        if let newDate = calendar.date(from: components) {
            viewModel.currentMonth = newDate
        }
    }
    
    func updateYear(_ year: Int) {
        var components = calendar.dateComponents([.year, .month, .day], from: viewModel.currentMonth)
        components.year = year
        if let newDate = calendar.date(from: components) {
            viewModel.currentMonth = newDate
        }
    }
    
    func heightForMode() -> CGFloat {
        switch viewModel.calendarMode {
        case .week: return 60
        case .fortnight: return 110
        case .month: return 280
        }
    }
    
    // Subview for Day Cell
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
                        .frame(width: 12, height: 12)
                        .transition(.scale)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 12, height: 12)
                }
            }
            .frame(height: 45)
        }
    }
    
    // Logic to switch between modes
    func visibleDays() -> [Date?] {
        switch viewModel.calendarMode {
        case .month:
            return daysInMonth()
        case .week:
            return daysInSelectedWeek()
        case .fortnight:
            return daysInSelectedFortnight()
        }
    }
    
    func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: viewModel.currentMonth),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.currentMonth))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: first)
        let offset = (firstWeekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for i in 0..<range.count {
            days.append(calendar.date(byAdding: .day, value: i, to: first))
        }
        return days
    }
    
    func daysInSelectedWeek() -> [Date?] {
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: viewModel.selectedDate)) else { return [] }
        
        var days: [Date?] = []
        for i in 0..<7 {
            days.append(calendar.date(byAdding: .day, value: i, to: startOfWeek))
        }
        return days
    }
    
    func daysInSelectedFortnight() -> [Date?] {
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: viewModel.selectedDate)) else { return [] }
        
        var days: [Date?] = []
        for i in 0..<14 {
            days.append(calendar.date(byAdding: .day, value: i, to: startOfWeek))
        }
        return days
    }
}

// MARK: - 5. SUMMARY & LIST COMPONENTS
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
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.3))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// MARK: - Shift Row
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
                
                // Show Break and Overtime details
                HStack(spacing: 5) {
                    if shift.breakDurationMinutes > 0 {
                        Text("Brk: \(Int(shift.breakDurationMinutes))m")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    if shift.overtimeMinutes > 0 {
                        if shift.breakDurationMinutes > 0 { Text("•").font(.caption2).foregroundColor(.gray) }
                        Text("OT: \(Int(shift.overtimeMinutes))m")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
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

// MARK: - 6. ADVANCED EDIT SHEET
struct AdvancedShiftEditView: View {
    
    @State var shift: Shift
    var onSave: (Shift) -> Void
    var onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    // Logic State
    @State private var startHour: Double = 9.0
    @State private var endHour: Double = 17.0
    @State private var breakDuration: Double = 30.0
    @State private var overtimeDuration: Double = 0.0
    
    // UI Text State
    @State private var startText: String = "09:00"
    @State private var endText: String = "17:00"
    @State private var breakText: String = "30"
    @State private var overtimeText: String = "0"
    
    let themeColor = Color(red: 91/255, green: 80/255, blue: 122/255)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Timeline Visualization
                    TimelineView(
                        startHour: startHour,
                        endHour: endHour,
                        breakDuration: breakDuration,
                        overtimeDuration: overtimeDuration
                    )
                    .frame(height: 80)
                    .padding(.top, 20)
                    
                    // Calculated Stats
                    HStack(spacing: 40) {
                        StatView(title: "Duration", value: String(format: "%.1f h", calculateDuration()))
                        StatView(title: "Overtime", value: "\(Int(overtimeDuration)) m")
                        StatView(title: "Break", value: "\(Int(breakDuration)) m")
                    }
                    
                    Divider()
                    
                    // Inputs
                    VStack(spacing: 25) {
                        
                        TimeInputRow(title: "Start Time", icon: "clock", text: $startText, themeColor: themeColor) {
                            validateAndUpdateStart()
                        }
                        
                        TimeInputRow(title: "End Time", icon: "clock.fill", text: $endText, themeColor: themeColor) {
                            validateAndUpdateEnd()
                        }
                        
                        BreakInputRow(title: "Break (min)", icon: "cup.and.saucer.fill", text: $breakText, themeColor: themeColor) {
                            validateAndUpdateBreak()
                        }
                        
                        OvertimeInputRow(title: "Overtime (min)", icon: "hourglass.badge.plus", text: $overtimeText, themeColor: themeColor) {
                            validateAndUpdateOvertime()
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        onDelete()
                        dismiss()
                    } label: {
                        Text("Delete Shift")
                            .foregroundColor(.red)
                            .padding()
                    }
                    
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
                loadFromModel()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    // Logic & Validation
    func loadFromModel() {
        let calendar = Calendar.current
        let startComp = calendar.dateComponents([.hour, .minute], from: shift.startTime)
        let endComp = calendar.dateComponents([.hour, .minute], from: shift.endTime)
        
        startHour = Double(startComp.hour ?? 0) + Double(startComp.minute ?? 0) / 60.0
        endHour = Double(endComp.hour ?? 0) + Double(endComp.minute ?? 0) / 60.0
        breakDuration = shift.breakDurationMinutes
        overtimeDuration = shift.overtimeMinutes
        
        startText = formatTimeForInput(hour: startHour)
        endText = formatTimeForInput(hour: endHour)
        breakText = "\(Int(breakDuration))"
        overtimeText = "\(Int(overtimeDuration))"
    }
    
    func updateShiftModel() {
        if endHour < startHour { endHour = startHour }
        
        shift.startTime = dateFromHour(startHour)
        shift.endTime = dateFromHour(endHour)
        shift.breakDurationMinutes = breakDuration
        shift.overtimeMinutes = overtimeDuration
    }
    
    func validateAndUpdateStart() {
        if let newHour = timeStringToDouble(startText) {
            withAnimation {
                startHour = newHour
                updateShiftModel()
            }
        }
    }
    
    func validateAndUpdateEnd() {
        if let newHour = timeStringToDouble(endText) {
            withAnimation {
                endHour = newHour
                updateShiftModel()
            }
        }
    }
    
    func validateAndUpdateBreak() {
        if let val = Double(breakText) {
            withAnimation {
                breakDuration = val
                updateShiftModel()
            }
        }
    }
    
    func validateAndUpdateOvertime() {
        if let val = Double(overtimeText) {
            withAnimation {
                overtimeDuration = val
                updateShiftModel()
            }
        }
    }
    
    func timeStringToDouble(_ time: String) -> Double? {
        let pattern = "^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$"
        guard time.range(of: pattern, options: .regularExpression) != nil else { return nil }
        
        let parts = time.split(separator: ":")
        guard parts.count == 2,
              let h = Double(parts[0]),
              let m = Double(parts[1]) else { return nil }
        return h + (m / 60.0)
    }
    
    func formatTimeForInput(hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        return String(format: "%02d:%02d", h, m)
    }
    
    func dateFromHour(_ value: Double) -> Date {
        let hour = Int(value)
        let minute = Int((value - Double(hour)) * 60)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: shift.date) ?? shift.date
    }
    
    func calculateDuration() -> Double {
        let raw = (endHour - startHour)
        let afterBreak = raw - (breakDuration / 60)
        let total = afterBreak + (overtimeDuration / 60)
        return max(0, total)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - 7. EDIT SHEET COMPONENTS
struct TimeInputRow: View {
    let title: String
    let icon: String
    @Binding var text: String
    let themeColor: Color
    var onCommit: () -> Void
    
    let timeOptions: [String] = {
        var times: [String] = []
        for h in 0..<24 {
            for m in [0, 15, 30, 45] {
                times.append(String(format: "%02d:%02d", h, m))
            }
        }
        return times
    }()
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.4))
                Spacer()
            }
            
            HStack(spacing: 0) {
                TextField("HH:mm", text: $text)
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.leading)
                    .font(.body.monospacedDigit())
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .onChange(of: text) { _ in
                        onCommit()
                    }
                
                Menu {
                    ScrollView {
                        ForEach(timeOptions, id: \.self) { time in
                            Button(time) {
                                text = time
                                onCommit()
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeColor)
                            .padding(.horizontal, 15)
                            .frame(maxHeight: .infinity)
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                    }
                }
            }
            .frame(height: 44)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

struct BreakInputRow: View {
    let title: String
    let icon: String
    @Binding var text: String
    let themeColor: Color
    var onCommit: () -> Void
    
    let options = [0, 15, 30, 45, 60]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.4))
                Spacer()
            }
            
            HStack(spacing: 0) {
                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.leading)
                    .font(.body.monospacedDigit())
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .onChange(of: text) { _ in
                        onCommit()
                    }
                
                Menu {
                    ForEach(options, id: \.self) { val in
                        Button("\(val) min") {
                            text = "\(val)"
                            onCommit()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeColor)
                            .padding(.horizontal, 15)
                            .frame(maxHeight: .infinity)
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                    }
                }
            }
            .frame(height: 44)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

struct OvertimeInputRow: View {
    let title: String
    let icon: String
    @Binding var text: String
    let themeColor: Color
    var onCommit: () -> Void
    
    let options = [0, 15, 30, 45, 60, 90, 120]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.4))
                Spacer()
            }
            
            HStack(spacing: 0) {
                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.leading)
                    .font(.body.monospacedDigit())
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .onChange(of: text) { _ in
                        onCommit()
                    }
                
                Menu {
                    ForEach(options, id: \.self) { val in
                        Button("\(val) min") {
                            text = "\(val)"
                            onCommit()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeColor)
                            .padding(.horizontal, 15)
                            .frame(maxHeight: .infinity)
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                    }
                }
            }
            .frame(height: 44)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

struct TimelineView: View {
    var startHour: Double
    var endHour: Double
    var breakDuration: Double
    var overtimeDuration: Double
    
    let workColor = Color(red: 136/255, green: 161/255, blue: 243/255)
    let breakColor = Color(red: 136/255, green: 161/255, blue: 243/255).opacity(0.35)
    let overtimeColor = Color(red: 83/255, green: 86/255, blue: 133/255)
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 40)
                
                HStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Text("\(i * 6)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .offset(y: 35)
                
                let shiftDurationHours = endHour - startHour
                let overtimeHours = overtimeDuration / 60.0
                
                let widthPerHour = geo.size.width / 24.0
                let startX = startHour * widthPerHour
                
                let totalVisualHours = shiftDurationHours + overtimeHours
                let totalBarWidth = max(0, totalVisualHours * widthPerHour)
                
                let totalShiftMinutes = shiftDurationHours * 60.0
                let actualWorkMinutes = max(0, totalShiftMinutes - breakDuration)
                let preBreakWork = actualWorkMinutes / 2.0
                let postBreakWork = actualWorkMinutes / 2.0
                
                let totalVisualMinutes = totalShiftMinutes + overtimeDuration
                
                if totalBarWidth > 0 && totalVisualMinutes > 0 {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(workColor)
                            .frame(width: (preBreakWork / totalVisualMinutes) * totalBarWidth)
                        
                        Rectangle()
                            .fill(breakColor)
                            .frame(width: (breakDuration / totalVisualMinutes) * totalBarWidth)
                        
                        Rectangle()
                            .fill(workColor)
                            .frame(width: (postBreakWork / totalVisualMinutes) * totalBarWidth)
                        
                        Rectangle()
                            .fill(overtimeColor)
                            .frame(width: (overtimeDuration / totalVisualMinutes) * totalBarWidth)
                    }
                    .frame(width: totalBarWidth, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .offset(x: startX)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: startHour)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: endHour)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: overtimeDuration)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: breakDuration)
                }
            }
        }
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

#Preview {
    RosterView()
}
