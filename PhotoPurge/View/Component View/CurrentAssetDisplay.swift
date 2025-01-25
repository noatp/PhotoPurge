//
//  CurrentAssetDisplay.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/22/25.
//

import SwiftUI

struct CurrentAssetDisplay: View {
    private let displayingAsset: DisplayingAsset
    
    init(displayingAsset: DisplayingAsset) {
        self.displayingAsset = displayingAsset
    }
    
    var body: some View {
        switch displayingAsset.assetType {
        case .photo:
            if let currentImage = displayingAsset.image {
                Image(uiImage: currentImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            }
        case .video:
            if let currentVideo = displayingAsset.video {
                CustomVideoPlayer(avPlayerItem: currentVideo)
                    
            }
        }
    }
}

#Preview {
    CurrentAssetDisplay(displayingAsset: .init(assetType: .photo, image: .init(named: "test1")))
}
