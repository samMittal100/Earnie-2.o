import SwiftUI
import Vision
import PhotosUI
import SwiftData

struct RosterScannerView: View {
    // MARK: - 1. ENVIRONMENT & STATE
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // UI State
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isScanning = false
    
    // Inputs & Results
    @State private var targetName: String = ""
    @State private var rosterDateRange: String = "Date not found"
    @State private var weeklyShifts: [DailyShift] = []
    @State private var totalHours: Double = 0.0
    @State private var statusMessage: String = "Ready to scan"
    @State private var debugInfo: String = ""
    
    // MARK: - 2. MAIN BODY
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: Scanner Controls
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Search Filter")
                            .font(.caption).bold().foregroundColor(.gray)
                        TextField("Enter Name (e.g. Cameron)", text: $targetName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                Image(systemName: "tablecells.badge.clock")
                                Text("Scan Roster Grid")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    if isScanning { ProgressView("Mapping Grid Coordinates...") }
                    
                    // MARK: Status Output
                    if !statusMessage.isEmpty && !isScanning {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(statusMessage.contains("Success") ? .green : .orange)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // MARK: Results & Save UI
                    if !weeklyShifts.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            // Header
                            VStack(alignment: .leading) {
                                Text("Roster: \(targetName)")
                                    .font(.headline)
                                Text(rosterDateRange)
                                    .font(.caption).bold().foregroundColor(.blue)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total Hours")
                                Spacer()
                                Text("\(String(format: "%.1f", totalHours))h")
                                    .font(.title2).bold().foregroundColor(.green)
                            }
                            
                            Divider()
                            
                            // Daily Breakdown
                            ForEach(weeklyShifts) { day in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(day.dayName) // e.g. "Monday"
                                            .font(.headline)
                                        Text(day.calculatedDateString) // e.g. "5 Feb"
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(day.timeString)
                                            .font(.system(.body, design: .monospaced))
                                        Text("\(String(format: "%.1f", day.hours))h")
                                            .font(.caption).bold().foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                            
                            // Save Button
                            Button(action: saveRoster) {
                                Text("Save Roster to Earnie")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Roster Scanner")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: selectedItem) {
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        scanRosterGrid(image: uiImage)
                    }
                }
            }
        }
    }
    
    // MARK: - 3. SAVE LOGIC
    func saveRoster() {
        for shift in weeklyShifts {
            // We use the 'targetName' as the employer name loosely
            let newRoster = Roster(
                employerName: "Work",
                shiftDate: shift.fullDate,
                startTime: shift.startTime,
                endTime: shift.endTime,
                totalHours: shift.hours
            )
            modelContext.insert(newRoster)
        }
        dismiss()
    }
    
    // MARK: - 4. OCR GRID ENGINE
    func scanRosterGrid(image: UIImage) {
        isScanning = true
        weeklyShifts = []
        totalHours = 0
        debugInfo = ""
        statusMessage = "Processing..."
        
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            guard let (headerY, columns) = self.mapGridStructure(observations) else {
                DispatchQueue.main.async {
                    self.statusMessage = "Could not find day headers (Mon, Tue, Wed...)."
                    self.isScanning = false
                }
                return
            }
            
            let startDate = self.parseStartDate(observations, headerY: headerY)
            
            guard let personY = self.findPersonRowY(name: targetName, observations: observations) else {
                DispatchQueue.main.async {
                    self.statusMessage = "Name '\(targetName)' not found."
                    self.isScanning = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.rosterDateRange = startDate != nil ? self.formatDate(startDate!) : "Date not found"
                self.statusMessage = "Success: Found \(targetName)"
                self.extractCells(personY: personY, columns: columns, observations: observations, startDate: startDate)
                self.isScanning = false
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async { try? handler.perform([request]) }
    }
    
    // Step 1: Map Grid
    func mapGridStructure(_ obs: [VNRecognizedTextObservation]) -> (CGFloat, [GridColumn])? {
        let dayKeywords = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        let shortKeywords = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
        
        let lines = Dictionary(grouping: obs) { Int($0.boundingBox.midY * 100) }
        var bestLineObs: [VNRecognizedTextObservation] = []
        var maxMatches = 0
        
        for (_, lineObs) in lines {
            var matchCount = 0
            for o in lineObs {
                let text = o.topCandidates(1).first?.string.lowercased() ?? ""
                if (dayKeywords.contains { text.hasPrefix($0) } || shortKeywords.contains { text.hasPrefix($0) }) {
                    matchCount += 1
                }
            }
            
            if matchCount > maxMatches {
                maxMatches = matchCount
                bestLineObs = lineObs
            }
        }
        
        if maxMatches < 4 { return nil }
        
        let headerY = bestLineObs.reduce(0) { $0 + $1.boundingBox.midY } / CGFloat(bestLineObs.count)
        
        var cols: [GridColumn] = []
        let sortedHeaders = bestLineObs
            .compactMap { obs -> (text: String, minX: CGFloat, maxX: CGFloat, midX: CGFloat)? in
                let text = obs.topCandidates(1).first?.string ?? ""
                let lower = text.lowercased()
                if (dayKeywords.contains { lower.hasPrefix($0) } || shortKeywords.contains { lower.hasPrefix($0) }) {
                    let bb = obs.boundingBox
                    return (text, bb.minX, bb.maxX, (bb.minX + bb.maxX) / 2)
                }
                return nil
            }
            .sorted { $0.midX < $1.midX }
        
        guard sortedHeaders.count >= 4 else { return nil }
        
        var centers = sortedHeaders.map { $0.midX }
        let edgeBuffer: CGFloat = 0.06
        let firstEdge = max(0.0, centers.first! - edgeBuffer)
        let lastEdge = min(1.0, centers.last! + edgeBuffer)
        
        var boundaries: [CGFloat] = [firstEdge]
        for i in 0..<(centers.count - 1) {
            let mid = (centers[i] + centers[i+1]) / 2
            boundaries.append(mid)
        }
        boundaries.append(lastEdge)
        
        cols = zip(0..<centers.count, sortedHeaders).map { (i, header) in
            let minX = boundaries[i]
            let maxX = boundaries[i+1]
            return GridColumn(name: header.text.capitalized, minX: minX, maxX: maxX)
        }
        
        return (headerY, cols)
    }

    // Step 2: Parse Start Date
    func parseStartDate(_ obs: [VNRecognizedTextObservation], headerY: CGFloat) -> Date? {
        let topObs = obs.filter { $0.boundingBox.minY > headerY }
        let pattern = #"(\d{1,2}\s*[a-zA-Z]{3})"#
        
        for o in topObs {
            let text = o.topCandidates(1).first?.string ?? ""
            if let range = text.range(of: pattern, options: .regularExpression) {
                let dateStr = String(text[range])
                let f = DateFormatter()
                f.dateFormat = "d MMM"
                if let date = f.date(from: dateStr) {
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: Date())
                    var comps = calendar.dateComponents([.day, .month], from: date)
                    comps.year = year
                    return calendar.date(from: comps)
                }
            }
        }
        return nil
    }

    // Step 3: Find Person Row
    func findPersonRowY(name: String, observations: [VNRecognizedTextObservation]) -> CGFloat? {
        if name.isEmpty { return nil }
        let target = name.lowercased()
        
        let dayTokens = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday","mon","tue","wed","thu","fri","sat","sun"]
        let headerCandidates = observations.filter { obs in
            let text = obs.topCandidates(1).first?.string.lowercased() ?? ""
            return dayTokens.contains { text.hasPrefix($0) }
        }
        let firstColX = headerCandidates.map { ($0.boundingBox.minX + $0.boundingBox.maxX)/2 }.min() ?? 0.25
        let nameGutterMaxX = max(0.05, min(0.45, firstColX - 0.02))
        
        let nearbyObs = observations.filter { $0.boundingBox.minX < nameGutterMaxX }
        for obs in nearbyObs {
            let text = obs.topCandidates(1).first?.string.lowercased() ?? ""
            if text.contains(target) {
                return obs.boundingBox.midY
            }
        }
        return nil
    }

    // Step 4: Extract Cells
    func extractCells(personY: CGFloat, columns: [GridColumn], observations: [VNRecognizedTextObservation], startDate: Date?) {
        var results: [DailyShift] = []
        let calendar = Calendar.current
        
        let nameGutterMaxX = columns.first.map { $0.minX - 0.02 } ?? 0.25
        let nearby = observations.filter { abs($0.boundingBox.midY - personY) < 0.05 && $0.boundingBox.minX < nameGutterMaxX }
        let lineHeight = nearby.map { $0.boundingBox.height }.max() ?? 0.05
        let rowHalfHeight = max(0.04, min(0.08, lineHeight * 1.4))
        
        let rowObs = observations.filter { abs($0.boundingBox.midY - personY) < rowHalfHeight }
        
        for (index, col) in columns.enumerated() {
            let cellObs = rowObs.filter { $0.boundingBox.midX > col.minX && $0.boundingBox.midX < col.maxX }
            let fullText = cellObs.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
            
            if !fullText.isEmpty {
                var shiftDate = Date()
                var dateStr = ""
                if let start = startDate, let d = calendar.date(byAdding: .day, value: index, to: start) {
                    shiftDate = d
                    dateStr = formatDate(d)
                }
                
                if let shift = parseTime(fullText, on: shiftDate) {
                    results.append(DailyShift(
                        dayName: col.name,
                        fullDate: shiftDate,
                        calculatedDateString: dateStr,
                        timeString: shift.label,
                        startTime: shift.start,
                        endTime: shift.end,
                        hours: shift.hours
                    ))
                }
            }
        }
        
        self.weeklyShifts = results
        self.totalHours = results.reduce(0) { $0 + $1.hours }
    }
    
    // MARK: - 5. TIME PARSERS
    func parseTime(_ text: String, on date: Date) -> (label: String, start: Date, end: Date, hours: Double)? {
        let clean = text.lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: ":")
        
        let rangePattern = #"(\d{1,2}(?::\d{2})?[ap]?[m]?)-(\d{1,2}(?::\d{2})?[ap]?[m]?)"#
        
        if let regex = try? NSRegularExpression(pattern: rangePattern),
           let match = regex.firstMatch(in: clean, range: NSRange(clean.startIndex..., in: clean)) {
            let sStr = (clean as NSString).substring(with: match.range(at: 1))
            let eStr = (clean as NSString).substring(with: match.range(at: 2))
            
            let (start, end, hours) = calculateDuration(sStr, eStr, on: date)
            
            if hours > 0 {
                return ("\(sStr) - \(eStr)", start, end, hours)
            }
        }
        return nil
    }
    
    func calculateDuration(_ s: String, _ e: String, on date: Date) -> (Date, Date, Double) {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        let formats = ["h:mma", "H:mm", "ha", "h"]
        
        func parseTimeOnly(_ t: String) -> Date? {
            var raw = t
            if !raw.contains(":") && !raw.contains("m") { raw += ":00" }
            for fmt in formats {
                f.dateFormat = fmt
                if let d = f.date(from: raw) { return d }
            }
            return nil
        }
        
        guard let t1 = parseTimeOnly(s), let t2 = parseTimeOnly(e) else { return (Date(), Date(), 0.0) }
        
        let calendar = Calendar.current
        let t1Comps = calendar.dateComponents([.hour, .minute], from: t1)
        let t2Comps = calendar.dateComponents([.hour, .minute], from: t2)
        
        var start = calendar.date(bySettingHour: t1Comps.hour!, minute: t1Comps.minute!, second: 0, of: date) ?? date
        var end = calendar.date(bySettingHour: t2Comps.hour!, minute: t2Comps.minute!, second: 0, of: date) ?? date
        
        if end < start {
            end = calendar.date(byAdding: .day, value: 1, to: end)!
        }
        
        let diff = end.timeIntervalSince(start)
        return (start, end, diff / 3600)
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }
}

// MARK: - 6. DATA MODELS
struct GridColumn {
    let name: String
    var minX: CGFloat
    var maxX: CGFloat
    var midX: CGFloat { (minX + maxX) / 2 }
}

struct DailyShift: Identifiable {
    let id = UUID()
    let dayName: String
    let fullDate: Date
    let calculatedDateString: String
    let timeString: String
    let startTime: Date
    let endTime: Date
    let hours: Double
}
