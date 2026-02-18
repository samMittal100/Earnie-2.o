
//
//  ErrorView.swift
//  Earnie
//
//  Created by Somya Mittal on 19/2/2026.
//

import SwiftUI

struct ErrorView: View {
    var message: String
    var dismissAction: () -> Void
    
    let darkPurple = Color(red: 0.35, green: 0.32, blue: 0.45)
    let errorRed = Color(red: 0.95, green: 0.3, blue: 0.3)
    
    var body: some View {
        ZStack {
            // Darkens the app background so the user focuses on the error
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                // Tapping the background also dismisses the error
                .onTapGesture { dismissAction() }
            
            VStack(spacing: 25) {
                // The Error Speech Bubble
                Text(message)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(darkPurple)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .background(
                        SpeechBubbleShape()
                            .fill(Color.white)
                            .overlay(SpeechBubbleShape().stroke(errorRed, lineWidth: 3))
                    )
                    .padding(.bottom, 20)
                
                // Earnie Mascot (You can reuse the exact same PNG)
                Image("characterRight")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    // Adding a grayscale filter makes him look "sad" or disabled
                    .grayscale(0.5)
                
                // Try Again Button
                Button(action: dismissAction) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(errorRed)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
            }
            .padding(30)
            // Adds a glassmorphism card behind Earnie and the text
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .shadow(radius: 20)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ErrorView(message: "Oops! I couldn't read that.\nMake sure the image is clear.") {
        print("Dismissed")
    }
}
