//
//  VideoPlayerView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/24/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let playerItem: AVPlayerItem
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(playerItem: playerItem)
        playerViewController.showsPlaybackControls = false
        playerViewController.player?.play()
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Safely update the player item without creating a new player
        uiViewController.player?.replaceCurrentItem(with: playerItem)
        uiViewController.player?.play()
    }
    
    // Ensure unique identity for view updates
    func _overrideTraitCollection(context: Context) -> UITraitCollection? {
        nil
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        uiViewController.player?.pause()
    }
}
