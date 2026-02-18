
//
//  AnalysisResultOverlay.swift
//  Earnie
//
//  Created by Somya Mittal on 18/2/2026.
//

import SwiftUI // Essential fix for the "View" scope error

struct AnalysisResultOverlay: View {
    let data: PayslipData
    var onDone: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background for focus
            Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                .onTapGesture { onDone() }
            
            VStack(spacing: 20) {
                Text("Payslip Analyzed")
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                
                VStack(spacing: 12) {
                    ResultRow(label: "Gross Pay", amount: data.grossPay, icon: "dollarsign.circle.fill", color: .blue)
                    ResultRow(label: "Tax Withheld", amount: data.tax, icon: "building.columns.fill", color: .orange)
                    ResultRow(label: "Superannuation", amount: data.superannuation, icon: "chart.bar.fill", color: .purple)
                    
                    Divider().background(Color.gray)
                    
                    ResultRow(label: "Net Pay", amount: data.netPay, icon: "arrow.down.circle.fill", color: .green)
                }
                .padding()
                .background(Color(white: 0.15))
                .cornerRadius(16)
                
                Button(action: onDone) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Local ResultRow Component
struct ResultRow: View {
    let label: String
    let amount: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2).foregroundColor(color).frame(width: 40)
            VStack(alignment: .leading) {
                Text(label).font(.caption).foregroundColor(.gray)
                Text("$\(amount)").font(.title3).fontWeight(.bold).foregroundColor(.white)
            }
            Spacer()
        }
        .padding(8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
