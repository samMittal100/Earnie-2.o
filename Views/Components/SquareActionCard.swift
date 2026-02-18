//
//  SquareActionCard.swift
//  Earnie
//
//  Created by Somya Mittal on 17/2/2026.
//

import SwiftUI

struct SquareActionCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(color.opacity(0.8))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(subtitle.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color(white: 0.15))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    HStack {
        SquareActionCard(title: "Upload Payslip", subtitle: "Step 1", icon: "doc.text.fill", color: .blue) {}
        SquareActionCard(title: "Upload Roster", subtitle: "Step 2", icon: "calendar", color: .green) {}
    }
    .padding()
    .background(Color.black)
}
