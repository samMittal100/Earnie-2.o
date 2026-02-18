//
//  Roster.swift
//  Earnie
//
//  Created by Somya Mittal on 18/2/2026.
//

import SwiftData
import Foundation

@Model
class Roster {
    var id: UUID
    var uploadDate: Date
    var employerName: String
    
    // Roster Specifics
    var shiftDate: Date      // The day of the shift (e.g., 5 Feb 2026)
    var startTime: Date      // e.g., 09:00 AM
    var endTime: Date        // e.g., 05:00 PM
    var breakDuration: Double // In minutes (default 0 for now)
    var totalHours: Double   // e.g., 7.5
    
    init(employerName: String, shiftDate: Date, startTime: Date, endTime: Date, totalHours: Double) {
        self.id = UUID()
        self.uploadDate = Date()
        self.employerName = employerName
        self.shiftDate = shiftDate
        self.startTime = startTime
        self.endTime = endTime
        self.breakDuration = 0.0 // Defaulting to 0 for auto-scanned shifts
        self.totalHours = totalHours
    }
}
