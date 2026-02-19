
//
//  LoopingVideoPlayer.swift
//  Earnie
//
//  Created by Somya Mittal on 19/2/2026.
//

import SwiftUI
import AVKit

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String
    let videoExtension: String

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName, videoExtension: videoExtension)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No update needed for a simple looping player
    }
}

class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?

    init(videoName: String, videoExtension: String) {
        super.init(frame: .zero)
        
        // Find the video in the app bundle
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("Brutal Reality: Could not find \(videoName).\(videoExtension) in the app bundle.")
            return
        }
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        // AVQueuePlayer is required for seamless looping
        let player = AVQueuePlayer()
        player.isMuted = true // Ensure it plays silently
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect // Keeps the proportions correct
        
        layer.addSublayer(playerLayer)
        
        // Create the looper
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        // Start playing immediately
        player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
