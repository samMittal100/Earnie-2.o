import SwiftUI

// 1. The Custom Mathematical Shape
struct SpeechBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cr: CGFloat = 20 // Corner Radius
        
        // Start top left and draw clockwise
        path.move(to: CGPoint(x: rect.minX + cr, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cr))
        path.addArc(center: CGPoint(x: rect.maxX - cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        // The Tail (drawn organically into the bottom line)
        path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - 5, y: rect.maxY + 18)) // Points down-right toward Earnie
        path.addLine(to: CGPoint(x: rect.maxX - 45, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX + cr, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cr))
        path.addArc(center: CGPoint(x: rect.minX + cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        return path
    }
}

// 2. The Updated Mascot View
struct MascotGreetingView: View {
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            
            // Seamless Speech Bubble
            Text("Hi! I'm Earnie.\nNice to meet you!")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(darkPurple)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    SpeechBubbleShape()
                        .fill(Color.white)
                        // This single line perfectly outlines the shape and tail together
                        .overlay(SpeechBubbleShape().stroke(darkPurple, lineWidth: 3))
                )
                .padding(.bottom, 25) // Lifts the bubble to align with Earnie's chest
            
            // The Mascot
            Image("EarnieMascot2")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// 3. The Preview
#Preview {
    ZStack {
        // Adding the background color so you can actually see the white bubble
        Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea()
        
        MascotGreetingView()
            .padding()
    }
}
