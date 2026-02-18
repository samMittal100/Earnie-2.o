
//
//  LoadingView.swift
//  Earnie
//
//  Created by Somya Mittal on 19/2/2026.
//

import SwiftUI

struct LoadingView: View {
    // The app's background color
    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.98)
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    
    // Animation States
    @State private var isBouncing = false
    @State private var showDot1 = false
    @State private var showDot2 = false
    @State private var showDot3 = false
    
    var body: some View {
        ZStack {
            // 1. Solid background to cover the screen beneath
            bgColor.ignoresSafeArea()
            
            // 2. Semi-transparent overlay to dim the screen
            Color.black.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: -10) {
                    // The Bouncing Mascot
                    Image("EarnieMascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        // The bounce animation
                        .offset(y: isBouncing ? -10 : 5)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                            value: isBouncing
                        )
                    
                    // The Thinking Dots
                    HStack(spacing: 4) {
                        ThinkingDot(isOn: showDot1)
                        ThinkingDot(isOn: showDot2)
                        ThinkingDot(isOn: showDot3)
                    }
                    .offset(y: -20) // Position near his head
                }
                
                Text("Earnie is thinking...")
                    .font(.headline)
                    .foregroundColor(darkPurple)
            }
        }
        .onAppear {
           startAnimations()
        }
    }
    
    func startAnimations() {
        // Start the main body bounce immediately
        isBouncing = true
        
        // Stagger the dots so they appear one by one
        withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
            showDot1 = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                showDot2 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                showDot3 = true
            }
        }
    }
}

// Helper Component for the dots
struct ThinkingDot: View {
    var isOn: Bool
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    
    var body: some View {
        Circle()
            .fill(darkPurple)
            .frame(width: 8, height: 8)
            .opacity(isOn ? 1 : 0.3)
            .scaleEffect(isOn ? 1 : 0.8)
    }
}

#Preview {
    LoadingView()
}
