//
//  DisplayingAsset.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/18/25.
//

import UIKit
import AVFoundation

enum AssetType {
    case photo
    case video
}

struct DisplayingAsset {
    let assetType: AssetType
    let video: AVPlayerItem?
    let image: UIImage?
    
    init(assetType: AssetType, video: AVPlayerItem? = nil, image: UIImage? = nil) {
        self.assetType = assetType
        self.video = video
        self.image = image
    }
}
