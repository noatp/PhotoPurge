//
//  VideoPlayerView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/24/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    init(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        print("VideoPlayerView init")
    }
    
    let playerItem: AVPlayerItem
    private static var sharedPlayer: AVPlayer = AVPlayer()
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        Task {
            await loadPlayerItem()
            
            // This will be executed after loadPlayerItem is finished
            playerViewController.player = VideoPlayerView.sharedPlayer
            playerViewController.showsPlaybackControls = false
            print("makeUIViewController")
            print(playerItem.automaticallyLoadedAssetKeys)
            print(playerItem.asset.status(of: .preferredTransform))
            print("start playing")
            playerViewController.player?.play()
        }
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player?.currentItem !== playerItem {
            Task {
                await loadPlayerItem()
                uiViewController.player = VideoPlayerView.sharedPlayer
                print("updateUIViewController")
                print(playerItem.automaticallyLoadedAssetKeys)
                print(playerItem.asset.status(of: .preferredTransform))
                print("start playing")
                uiViewController.player?.play()
            }
        }
    }
    
    func _overrideTraitCollection(context: Context) -> UITraitCollection? {
        nil
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        sharedPlayer.pause()
    }
    
    private func loadPlayerItem() async {
        let asset = playerItem.asset
        do {
            let (_, _, preferredTransform) = try await asset.load(.tracks, .duration, .preferredTransform)
            let item = AVPlayerItem(asset: asset)
            VideoPlayerView.sharedPlayer.replaceCurrentItem(with: item)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
