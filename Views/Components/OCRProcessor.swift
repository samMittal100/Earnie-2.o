//
//  OCRProcessor.swift
//  Earnie
//
//  Created by Somya Mittal on 18/2/2026.
//

import Vision
import UIKit

// The Data Structure
struct PayslipData: Equatable {
    var grossPay: String = "0.00"
    var tax: String = "0.00"
    var netPay: String = "0.00"
    var superannuation: String = "0.00"
}

class OCRProcessor {
    
    // Universal Entry Point: Call this from anywhere (Camera, Photos, PDF)
    static func recognizeText(from image: UIImage, completion: @escaping (PayslipData) -> Void) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            // 1. Group text into lines (Jeff's Logic)
            let rows = groupObservationsIntoRows(observations)
            
            // 2. Parse the lines (Smart Logic with Fix)
            let results = parseRows(rows)
            
            // 3. Return Data
            let data = PayslipData(
                grossPay: results.gross,
                tax: results.tax,
                netPay: results.net,
                superannuation: results.superAmount
            )
            
            DispatchQueue.main.async { completion(data) }
        }
        
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async { try? handler.perform([request]) }
    }
    
    // ==========================================
    // MARK: - JEFF'S SORTING LOGIC (UNTOUCHED)
    // ==========================================
    
    private static func groupObservationsIntoRows(_ observations: [VNRecognizedTextObservation]) -> [PayslipRow] {
        // Sort by height (Top to Bottom)
        let sortedObservations = observations.sorted { $0.boundingBox.maxY > $1.boundingBox.maxY }
        var rows: [PayslipRow] = []
        
        for obs in sortedObservations {
            guard let _ = obs.topCandidates(1).first?.string else { continue }
            let yPosition = obs.boundingBox.midY
            
            // Tolerance 0.02
            if let rowIndex = rows.firstIndex(where: { abs($0.yPosition - yPosition) < 0.02 }) {
                rows[rowIndex].items.append(obs)
            } else {
                rows.append(PayslipRow(yPosition: yPosition, items: [obs]))
            }
        }
        
        // Sort items inside each row from Left to Right
        for i in 0..<rows.count {
            rows[i].items.sort { $0.boundingBox.minX < $1.boundingBox.minX }
        }
        
        return rows
    }
    
    // ==========================================
    // MARK: - SMART PARSER (THE FIX)
    // ==========================================
    
    private static func parseRows(_ rows: [PayslipRow]) -> (gross: String, net: String, tax: String, superAmount: String) {
        var gross = "0.00"
        var net = "0.00"
        var tax = "0.00"
        var superAmount = "0.00"
        
        // Track confidence to avoid overwriting good data with bad data
        var foundTotalGross = false
        var foundTotalNet = false
        
        for row in rows {
            let fullRowText = row.fullText.lowercased()
            let numbersInRow = row.extractNumbers()
            
            guard let val = numbersInRow.last else { continue }
            
            // --- 1. GROSS PAY STRATEGY ---
            if fullRowText.contains("total gross") || fullRowText.contains("total wages") {
                // Gold Standard: "Total Gross" is definitely correct.
                gross = val
                foundTotalGross = true
            }
            else if (fullRowText.contains("gross") || fullRowText.contains("total pay")) {
                // Silver Standard: "Gross" is okay, BUT only if:
                // 1. We haven't found the "Total" yet.
                // 2. It DOES NOT say "YTD" (This fixes the footer bug).
                if !foundTotalGross && !fullRowText.contains("ytd") {
                    gross = val
                }
            }
            
            // --- 2. NET PAY STRATEGY ---
            if fullRowText.contains("net pay") {
                net = val
                foundTotalNet = true
            }
            else if (fullRowText.contains("bank") || fullRowText.contains("take home")) && !foundTotalNet {
                net = val
            }
            
            // --- 3. TAX STRATEGY ---
            if fullRowText.contains("tax") || fullRowText.contains("payg") || fullRowText.contains("withheld") {
                // Ignore "Tax YTD" in footer
                if !fullRowText.contains("ytd") {
                    tax = val
                }
            }
            
            // --- 4. SUPER STRATEGY ---
            if fullRowText.contains("super") || fullRowText.contains("sgc") {
                // Ignore "Superable Salary" headers or YTD totals
                if !fullRowText.contains("salary") && !fullRowText.contains("ytd") {
                    superAmount = val
                }
            }
        }
        
        return (gross, net, tax, superAmount)
    }
}

// Jeff's Helper Struct
struct PayslipRow {
    var yPosition: CGFloat
    var items: [VNRecognizedTextObservation]
    
    var fullText: String {
        return items.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
    }
    
    func extractNumbers() -> [String] {
        let text = fullText
        // Regex for currency (matches 1,234.56)
        let pattern = #"[0-9,]+\.[0-9]{2}"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map { String(text[Range($0.range, in: text)!]) }
        } catch { return [] }
    }
}
