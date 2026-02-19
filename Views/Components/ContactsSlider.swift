//
//  ContactsSlider.swift
//  Earnie
//
//  Created by Mathanghi Alahapphan on 19/2/2026.
//

import SwiftUI

struct ContactsSlider: View {
    // MARK: - Custom Colors (Extracted from Old File)
    let customPhoneColor = Color(red: 77/255, green: 65/255, blue: 101/255)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                
                // 1. Fair Work
                ContactCard(name: "Fair Work", subtitle: "fairwork.gov.au", phone: "13 13 94")
                
                // 2. ATO (General)
                ContactCard(name: "ATO", subtitle: "ato.gov.au", phone: "13 28 61")

                // 3. ATO (Tax Help)
                ContactCard(name: "ATO (Tax Help)", subtitle: "ato.gov.au", phone: "1800 287 287")
                
                // 4. Working Women's
                ContactCard(name: "Working Women's", subtitle: "wwc.org.au", phone: "1800 992 842")
                
                // 5. RAFFWU
                ContactCard(name: "RAFFWU", subtitle:"raffwu.org.au", phone: "1300 723 398")
            }
            .padding(.bottom, 20)
            .padding(.leading, 20) // Adjusted padding to match New File's layout needs
            .padding(.trailing, 20)
        }
    }

    // MARK: - CONTACT CARD COMPONENT (Extracted from Old File)
    struct ContactCard: View {
        let name: String
        let subtitle: String
        let phone: String
        var isWebsite: Bool = false
        
        // Exact Color: #4d4165 (RGB: 77, 65, 101)
        let customPhoneColor = Color(red: 77/255, green: 65/255, blue: 101/255)

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Subtitle Row (Links are Blue)
                HStack {
                    let isLink = subtitle.contains(".")
                    Image(systemName: "globe")
                        .font(.caption)
                        .foregroundColor(isLink ? .blue : .gray)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isLink ? .blue : .gray)
                        .lineLimit(1)
                }

                // Phone Row (UPDATED COLOR: #4d4165)
                HStack {
                    Image(systemName: isWebsite ? "safari.fill" : "phone.fill")
                        .font(.caption)
                        .foregroundColor(isWebsite ? .blue : customPhoneColor)
                    Text(phone)
                        .font(.caption)
                        .foregroundColor(isWebsite ? .blue : customPhoneColor)
                        .lineLimit(1)
                }
            }
            .padding()
            .frame(width: 170, alignment: .leading)
            // WATER GLASSY EFFECT
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.9), Color.blue.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: Color.blue.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
}
