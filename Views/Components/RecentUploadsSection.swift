//
//  RecentUploadsSection.swift
//  Earnie
//
//  Created by Somya Mittal on 18/2/2026.
//

import SwiftUI // Essential fix

struct RecentUploadsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Uploads")
                .font(.headline)
                .foregroundColor(Color(red: 0.35, green: 0.32, blue: 0.45)) // Prototype dark purple
            
            VStack(spacing: 12) {
                // Matches the "Pending" row in your prototype
                UniversalButton(
                    title: "October Pay Slip - Pending",
                    icon: "doc.text.fill",
                    subtitle: "Pending Review",
                    statusColor: .gray,
                    rightIcon: "clock.fill",
                    backgroundColor: .white
                ) { }
                
                // Matches the "Approved" blue-tinted row in your prototype
                UniversalButton(
                    title: "September Invoice - Approved",
                    icon: "doc.text.fill",
                    subtitle: "Review",
                    statusColor: .blue,
                    rightIcon: "checkmark.circle.fill",
                    backgroundColor: Color.blue.opacity(0.1)
                ) { }
            }
        }
    }
}
