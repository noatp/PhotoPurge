//
//  CustomVideoPlayer.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/24/25.
//

import SwiftUI
import AVKit

struct CustomVideoPlayer: View {
    @ObservedObject var manager = SinglePlayerManager.shared
    
    private let avPlayerItem: AVPlayerItem
    
    init(avPlayerItem: AVPlayerItem) {
        self.avPlayerItem = avPlayerItem
    }
    
    var body: some View {
        VideoPlayer(player: manager.player)
            .onAppear {
                manager.setItem(avPlayerItem)
            }
            .onChange(of: avPlayerItem) { oldValue, newValue in
                SinglePlayerManager.shared.setItem(avPlayerItem)
            }
            .onDisappear {
                SinglePlayerManager.shared.stop()
            }
    }
}

#Preview {
    CustomVideoPlayer(avPlayerItem: .init(url: .init(string: "")!))
}


class SinglePlayerManager: ObservableObject {
    static let shared = SinglePlayerManager()
    
    @Published var player: AVPlayer
    
    private init() {
        self.player = AVPlayer()
    }
    
    func setItem(_ item: AVPlayerItem) {
        // Replace the current item on the single shared player
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func stop() {
        player.pause()
    }
}
