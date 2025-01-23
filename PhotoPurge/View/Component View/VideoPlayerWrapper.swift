//
//  VideoPlayerWrapper.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/22/25.
//

import SwiftUI
import AVKit

struct VideoPlayerWrapper: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .id(videoURL) // This forces the view to recreate
            .onAppear {
                initializePlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
            .onChange(of: videoURL) { _, newURL in
                updatePlayer(with: newURL)
            }
    }
    
    private func initializePlayer() {
        player = AVPlayer(url: videoURL)
        player?.play()
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
    }
    
    private func updatePlayer(with url: URL) {
        // If the URL changes, create a new AVPlayer instance
        player = AVPlayer(url: url)
        player?.play() // Auto-play the new video
    }
}
