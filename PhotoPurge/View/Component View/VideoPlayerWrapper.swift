//
//  VideoPlayerWrapper.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/22/25.
//

import SwiftUI
import AVKit

struct VideoPlayerWrapper: View {
    let video: AVPlayerItem
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
//            .id(videoURL) // This forces the view to recreate
            .onAppear {
                initializePlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
            .onChange(of: video) { _, newVideo in
                updatePlayer(with: newVideo)
            }
    }
    
    private func initializePlayer() {
        player = AVPlayer(playerItem: video)
        player?.play()
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
    }
    
    private func updatePlayer(with video: AVPlayerItem) {
        // If the URL changes, create a new AVPlayer instance
        player = AVPlayer(playerItem: video)
        player?.play() // Auto-play the new video
    }
}
