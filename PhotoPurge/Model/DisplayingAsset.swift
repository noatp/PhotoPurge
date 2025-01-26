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
    case ads
}

struct DisplayingAsset: Equatable {
    let assetType: AssetType
    let video: AVPlayerItem?
    let image: UIImage?
    
    init(assetType: AssetType, video: AVPlayerItem? = nil, image: UIImage? = nil) {
        self.assetType = assetType
        self.video = video
        self.image = image
    }
    
    static let empty = DisplayingAsset(assetType: .photo)
    static let ads = DisplayingAsset(assetType: .ads)
}
